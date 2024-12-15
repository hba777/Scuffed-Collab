import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:scuffed_collab/models/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import '../models/ProjectsModel.dart';
import '../models/TaskModel.dart';
import '../models/TeamModel.dart';
import 'accessToken.dart';

// For WorkManager Notification
@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await FirebaseApi.checkForPendingTasks();
    return Future.value(true);
  });
}

class FirebaseApi {
  ///For authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  ///For accessing Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  ///Firebase Messaging Access
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  ///For Getting Firebase Message Token
  static Future<void> getFirebaseMessagingToken() async{
    await fmessaging.requestPermission(
    );

    fmessaging.getToken().then((t) {
      if(t != null){
        me.pushToken = t;
        log('Push Token $t');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  ///Storing self info
  static late UserModel me;

  //For Notifications
  static Future<void> sendPushNotification(String token, String title, String body) async {
    AccessFirebaseToken accessToken = AccessFirebaseToken();
    String bearerToken = await accessToken.getAccessToken();
    final notificationBody = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body
        },
      }
    };

    try {
      var res = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/scuffed-collab/messages:send'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $bearerToken'
        },
        body: jsonEncode(notificationBody),
      );
      print("Response statusCode: ${res.statusCode}");
      print("Response body: ${res.body}");
    } catch (e) {
      print("\nsendPushNotification: $e");
    }
  }

  /// Fetch tasks across all projects
  static Future<List<TaskModel>> getAllNotificationTasks() async {
    List<TaskModel> allTasks = [];
    try {
      final projectSnapshot = await firestore.collection('Projects').get();

      for (var projectDoc in projectSnapshot.docs) {
        final taskSnapshot = await projectDoc.reference.collection('tasks').get();
        for (var taskDoc in taskSnapshot.docs) {
          allTasks.add(TaskModel.fromJson(taskDoc.data()));
        }
      }
    } catch (e) {
      log('Error fetching tasks for notification: $e');
    }
    return allTasks;
  }

  static Future<void> checkForPendingTasks() async {
    final tasks = await getAllNotificationTasks();
    DateTime today = DateTime.now();

    for (TaskModel task in tasks) {
      if (task.status == 'Pending' || task.status == 'In Progress') {
        DateTime taskDeadline = DateFormat('dd-MM-yyyy').parse(task.deadline);
        DateTime notificationDate = taskDeadline.subtract(const Duration(days: 2));

        if (today.isAtSameMomentAs(notificationDate)) {
          // Locate team member push token by assigned email
          final projectId = task.projectId;
          final teamSnapshot = await firestore
              .collection('Projects')
              .doc(projectId)
              .collection('team')
              .where('Email', isEqualTo: task.assignedTo)
              .limit(1)
              .get();

          if (teamSnapshot.docs.isNotEmpty) {
            final assignedMember = teamSnapshot.docs.first;
            final String? pushToken = assignedMember.data()['push_token'];

            // Send notification if push token is available
            if (pushToken != null && pushToken.isNotEmpty) {
              await sendPushNotification(
                pushToken,
                "Task Reminder",
                "The task '${task.title}' is pending and due in 2 days.",
              );
            }
          }
        }
      }
    }
  }


  ///Checking if user exists
  static Future<bool> userExists() async {
    return (await firestore.collection('Users').doc(user.uid).get()).exists;
  }

  ///Getting current user info
  static Future<void> getSelfInfo() async {
    (await firestore.collection('Users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = UserModel.fromJson(user.data()!);

        //CompileSdk must be set to 33 or check terminal
        await getFirebaseMessagingToken();

        //For setting user status to active
        //Set User Status to Active
        updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    }));
  }
  ///Creating new user
  static Future<void> createUser() async {
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    final appUser = UserModel(
        id: user.uid,
        Name: user.displayName.toString(),
        Email: user.email.toString(),
        About: 'Hey, Im Using Niko Chats',
        Image: user.photoURL.toString(),
        CreatedAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('Users')
        .doc(user.uid)
        .set(appUser.toJson());
  }

  ///Update Active Status
  static Future<void> updateActiveStatus(bool isOnline) async {
    final batch = firestore.batch();

    try {
      // Update the user's status in the main `Users` collection
      firestore.collection('Users').doc(user.uid).update({
        'is_Online': isOnline,
        'last_Active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me.pushToken,
      });

      // Fetch all projects where the current user is a team member
      final projectSnapshot = await firestore.collection('Projects').get();

      for (var projectDoc in projectSnapshot.docs) {
        final teamSnapshot = await projectDoc.reference.collection('team').where('id', isEqualTo: me.id).get();

        // If the user is found in the team subcollection, update their `isOnline` status
        if (teamSnapshot.docs.isNotEmpty) {
          for (var memberDoc in teamSnapshot.docs) {
            batch.update(memberDoc.reference, {
              'is_Online': isOnline,
              'last_Active': DateTime.now().millisecondsSinceEpoch.toString(),
            });
          }
        }
      }

      // Commit all updates in a single batch
      await batch.commit();
      log('Active status updated for team members successfully.');
    } catch (e) {
      log('Error updating active status for team members: $e');
    }
  }


  ///Updating user info
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('Users')
        .doc(user.uid)
    //Update and set difference.Update only update existing field, Set creates new field
        .update({'name': me.Name, 'About': me.About});
  }

  ///Updating user Profile Picture
  static Future<void> updateProfilePicture(File file) async {
    try {
      // Get image file extension
      final ext = file.path.split('.').last;
      log('Extension $ext');

      // Storage file reference with path
      final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

      // Uploading Image and waiting for completion
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} KB');
      });

      // Updating image URL in user profile
      me.Image = await ref.getDownloadURL();
      await firestore
          .collection('Users')
          .doc(user.uid)
          .update({'Image': me.Image, 'About': me.About});

      // Go through each project, update profile picture in 'team' subcollection
      final projectsSnapshot = await firestore.collection('Projects').get();
      for (var project in projectsSnapshot.docs) {
        // Get the 'team' subcollection
        final teamSnapshot = await project.reference.collection('team').get();
        for (var teamMember in teamSnapshot.docs) {
          // Check if team member ID matches the user's ID
          if (teamMember.id == me.id) {
            // Update the profile picture URL in the team member's document
            await teamMember.reference.update({'Image': me.Image});
          }
        }
      }
      log('Profile picture updated in all projects.');
    } catch (e) {
      log('Error updating profile picture: $e');
    }
  }


  //Check User Exists based on email

  static Future<TeamMember?> getTeamMemberByEmail(String email) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('Email', isEqualTo: email)
          .limit(1) // Limit to 1 as we only need one matching document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        // Map the data to a TeamMember object
        TeamMember teamMember = TeamMember.fromJson(userData);
        log('TeamMember ${teamMember.email}');
        return teamMember;
      } else {
        return null; // No user found with the given email
      }
    } catch (e) {
      print("Error retrieving team member: $e");
      return null; // Return null on error
    }
  }


  /// Getting all projects for which the current user is a team member
  static Future<List<Projects>> getAllProjects() async {
    List<Projects> projectList = [];
    try {
      // Fetch all project documents
      QuerySnapshot projectSnapshot = await firestore.collection('Projects').get();

      // Loop through each project and check if the user is a team member
      for (var projectDoc in projectSnapshot.docs) {
        // Check if the current user is a member of this project
        QuerySnapshot teamMembersSnapshot = await projectDoc.reference.collection('team').where('id', isEqualTo: me.id).get();

        if (teamMembersSnapshot.docs.isNotEmpty) {
          // If the user is a team member, add the project to the list
          projectList.add(Projects.fromJson(projectDoc.data() as Map<String, dynamic>));
        }
      }
    } catch (e) {
      log('Error fetching projects: $e');
      // Return an empty list on error.
      return [];
    }
    return projectList;
  }


  /// Creating a new project with a random ID and sending a notification

  static Future<void> createProject(
      String projectTitle,
      String projectDescription,
      String projectDeadline,
      List<TeamMember> teamMembers,
      ) async {
    try {
      final projectRef = firestore.collection('Projects').doc();
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final Projects project = Projects(
        id: projectRef.id,
        title: projectTitle,
        createdAt: time,
        deadline: projectDeadline,
        description: projectDescription,
      );

      log('Deadline: $projectDeadline');
      await projectRef.set(project.toJson());

      for (TeamMember member in teamMembers) {
        final teamMemberRef = projectRef.collection('team').doc(member.id);
        await teamMemberRef.set(member.toJson());

        // Send push notification to each team member
        if (member.pushToken.isNotEmpty) {
          await sendPushNotification(
            member.pushToken,
            projectTitle,
            projectDescription,
          );
        }
      }

      log('Project created with ID: ${projectRef.id}');
    } catch (e) {
      log('Error creating project: $e');
    }
  }

  /// Deleting a project by its ID
  static Future<void> deleteProject(String projectId) async {
    try {
      // Reference to the specific project document
      final projectRef = firestore.collection('Projects').doc(projectId);

      // Get all tasks under the project and delete them
      final taskSnapshot = await projectRef.collection('tasks').get();
      for (var taskDoc in taskSnapshot.docs) {
        await taskDoc.reference.delete();
      }

      // Get all team members under the project and delete them
      final teamSnapshot = await projectRef.collection('team').get();
      for (var memberDoc in teamSnapshot.docs) {
        await memberDoc.reference.delete();
      }

      // Finally, delete the project document itself
      await projectRef.delete();

      log('Project with ID $projectId deleted successfully, including all tasks and team members.');
    } catch (e) {
      log('Error deleting project with ID $projectId: $e');
    }
  }


  /// Getting a specific project -- Change sometime
  static Future<Projects?> getProject(String projectId) async {
    try {
      final docSnapshot = await firestore.collection('Projects').doc(projectId).get();
      if (docSnapshot.exists) {
        return Projects.fromJson(docSnapshot.data()!);
      }
    } catch (e) {
      log('Error fetching project: $e');
    }
    return null;
  }

  /// Getting all team members for a project
  static Future<List<TeamMember>> getTeamMembers(String projectId) async {
    List<TeamMember> teamMembers = [];
    try {
      final snapshot = await firestore.collection('Projects').doc(projectId).collection('team').get();
      for (var doc in snapshot.docs) {
        teamMembers.add(TeamMember.fromJson(doc.data()));
      }
    } catch (e) {
      log('Error fetching team members: $e');
    }
    return teamMembers;
  }

  /// Getting all tasks for a project
  static Future<List<TaskModel>> getTasks(String projectId) async {
    List<TaskModel> tasks = [];
    try {
      final snapshot = await firestore.collection('Projects').doc(projectId).collection('tasks').get();
      for (var doc in snapshot.docs) {
        tasks.add(TaskModel.fromJson(doc.data()));
      }
    } catch (e) {
      log('Error fetching tasks: $e');
    }
    return tasks;
  }

  /// Creating a team member for a project
  static Future<void> addTeamMember(Projects project, TeamMember member) async {
    try {
      await firestore.collection('Projects').doc(project.id).collection('team').doc(member.id).set(member.toJson());

      await sendPushNotification(
        member.pushToken!,
        'You have been added to Project: ${project.title}',
        project.description,
      );
    } catch (e) {
      log('Error adding team member: $e');
    }
  }

  /// Removing a team member from a project
  static Future<void> removeTeamMember(Projects project, TeamMember member) async {
    try {
      // Optional: Notify the removed member about their removal
      await sendPushNotification(
        member.pushToken!,
        'Removed from Project: ${project.title}',
        'You have been removed from the project: ${project.title}.',
      );
      // Remove the member document from the project's 'team' sub-collection
      await firestore.collection('Projects').doc(project.id).collection('team').doc(member.id).delete();

    } catch (e) {
      log('Error removing team member: $e');
    }
  }

  /// Creating a task for a project
  static Future<void> addTask(
      String projectId,
      String taskTitle,
      String taskDescription,
      String taskDeadline,
      String assignedTo,
      String taskStatus,
      ) async {
    try {
      final taskRef = firestore.collection('Projects').doc(projectId).collection('tasks').doc();
      final TaskModel task = TaskModel(
        id: taskRef.id,
        title: taskTitle,
        description: taskDescription,
        assignedTo: assignedTo,
        status: taskStatus,
        deadline: taskDeadline,
        projectId: projectId
      );
      await taskRef.set(task.toJson());

      // Retrieve the assigned team member's push token
      TeamMember? assignedMember = await getTeamMemberByEmail(assignedTo);
      if (assignedMember != null && assignedMember.pushToken != null && assignedMember.pushToken!.isNotEmpty) {
        await sendPushNotification(
          assignedMember.pushToken!,
          taskTitle,
          taskDescription,
        );
      }
    } catch (e) {
      log('Error creating task: $e');
    }
  }

  /// Updating task status
  static Future<void> updateTaskStatus(String projectId, String taskId, String newStatus) async {
    try {
      // Reference to the specific task document within the tasks subcollection of the project
      final taskRef = firestore.collection('Projects').doc(projectId).collection('tasks').doc(taskId);

      // Update the status field of the task document
      await taskRef.update({'status': newStatus});
      log('Task status updated successfully to $newStatus');
    } catch (e) {
      log('Error updating task status: $e');
    }
  }

  /// Deleting a task
  static Future<void> deleteTask(String projectId, String taskId) async {
    try {
      // Reference to the specific task document within the tasks subcollection of the project
      final taskRef = firestore.collection('Projects').doc(projectId).collection('tasks').doc(taskId);

      // Delete the task document
      await taskRef.delete();
      log('Task deleted successfully');
    } catch (e) {
      log('Error deleting task: $e');
    }
  }



}