import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scuffed_collab/helper/dailogs.dart';
import 'package:scuffed_collab/models/TeamModel.dart';
import 'package:scuffed_collab/screens/homeScreen/homeBloc/home_bloc.dart';
import 'package:scuffed_collab/screens/projectScreen/projectBloc/project_details_bloc.dart';
import 'package:scuffed_collab/screens/projectScreen/ui/project_memberAdd_screen.dart';
import 'package:scuffed_collab/screens/projectScreen/ui/task_creation_screen.dart';
import 'package:scuffed_collab/screens/projectScreen/ui/task_screen.dart';

import '../../../main.dart';
import '../../../models/ProjectsModel.dart';

class ProjectScreen extends StatelessWidget {
  final Projects project;
  final HomeBloc homeBloc;

  const ProjectScreen({super.key, required this.project, required this.homeBloc});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectDetailsBloc, ProjectDetailsState>(
      listenWhen: (previous, current) => current is ProjectDetailsActionState,
      buildWhen: (previous, current) => current is! ProjectDetailsActionState,
      listener: (context, state) {
        // TODO: implement listener
        if(state is ProjectDetailsAddTaskBtnNavState) {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
          BlocProvider.value(
            value: context.read<ProjectDetailsBloc>(),
            child: CreateTaskScreen(teamMembers: state.teamMembers, project: project,),)));
        } else if (state is ProjectDetailsMemberBtnNavState) {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
              BlocProvider.value(
                  value: context.read<ProjectDetailsBloc>(),
                  child: TeamMemberAddScreen(project: project,))
          ));
        } else if (state is TaskClickedNavState){
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
              BlocProvider.value(
                value: context.read<ProjectDetailsBloc>(),
                child: TaskScreen(project: project,task: state.task))
          ));
        } else if (state is ProjectDetailsDeleteBtnNavState){
          //Close Dialog
          Navigator.pop(context);
          //Close Screen and go back to home
          //Navigator.pop(context);
        } else if (state is ProjectDetailsErrorState){
          Dialogs.showSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: mq.width * .05,
                ),
              ),
              title: Text(
                project.title,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                //Add Members
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width *.02),
                  child: InkWell(
                    onTap: (){
                      context.read<ProjectDetailsBloc>().add(ProjectDetailsMemberBtnEvent());
                    },
                      child: const Icon(CupertinoIcons.person, color: Colors.white,)),
                ),

                //Delete Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width *.02),
                  child: InkWell(
                      onTap: (){
                        _showDeleteConfirmationDialog(context, project, homeBloc);
                      },
                      child: const Icon(Icons.cancel_outlined, color: Colors.redAccent,)),
                )
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF111111),
                onPressed: () {
                  // Add Task button action
                  context.read<ProjectDetailsBloc>().add(ProjectDetailsAddTaskButtonEvent(projectId: project.id));
                },
                label: Text(
                  'Add Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: mq.width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: mq.height * .02),

                // Team Members Heading
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .02),
                  child: Text(
                    'Team Members',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: mq.width * .045,
                    ),
                  ),
                ),

                // Team Members List
                _buildTeamMemberList(state, project),

                SizedBox(height: mq.height *.02,),
                // Tasks Heading
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .02),
                  child: Text(
                    'Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: mq.width * .045,
                    ),
                  ),
                ),

                // Task List
                Expanded(child: _buildTaskList(state)),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildTeamMemberList(ProjectDetailsState state, Projects project) {
  if (state is ProjectDetailsSuccessState) {
    if (state.teamMembers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No team members added.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.width * .02),
      child: SizedBox(
        height: mq.width * .16, // Set height to accommodate the avatar size
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Horizontal scrolling
          itemCount: state.teamMembers.length,
          itemBuilder: (context, index) {
            final member = state.teamMembers[index];

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .02), // Spacing between avatars
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Avatar
                  CircleAvatar(
                    radius: mq.width * .08, // Adjust the size as needed
                    backgroundColor: Colors.grey.shade200, // Background color in case image fails to load
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: member!.profilePicture,
                        fit: BoxFit.cover, // Ensures the image fits within the circle without distortion
                        width: mq.width * .16, // Matches the CircleAvatar size (diameter)
                        height: mq.width * .16, // Matches the CircleAvatar size (diameter)
                        errorWidget: (context, url, error) => const Icon(Icons.error), // Error icon in case image fails
                      ),
                    ),
                  ),
                  // Status indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: mq.width * .02, // Adjust the size of the status indicator
                      backgroundColor: member.isOnline ? Colors.greenAccent : Colors.yellow,
                    ),
                  ),
                  // Red circle with cross icon
                  Positioned(
                    top: -mq.width * .015, // Slightly offset to the outside
                    right: -mq.width * .015, // Slightly offset to the outside
                    child: GestureDetector(
                      onTap: () {
                        _showMemberDeleteConfirmationDialog(context, project, member);
                        },
                      child: CircleAvatar(
                        radius: mq.width * .03, // Adjust the size of the red circle
                        backgroundColor: Colors.red, // Red background color
                        child: const Icon(
                          Icons.close,
                          size: 16, // Adjust the size of the cross icon
                          color: Colors.white, // White cross icon
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  } else if (state is ProjectDetailsLoadingState) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.greenAccent,
      ),
    );
  }
  return const Center(
    child: Text(
      'No team members added.',
      style: TextStyle(color: Colors.white70),
    ),
  );
}


Widget _buildTaskList(ProjectDetailsState state) {
  if (state is ProjectDetailsSuccessState) {
    if (state.tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No Tasks added.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.tasks.length,
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return Padding( // Adding padding around the Card for spacing
          padding: EdgeInsets.symmetric(vertical: mq.height * .01, horizontal: mq.width * .03),
          child: InkWell(
            onTap: (){
              context.read<ProjectDetailsBloc>().add(TaskClickedEvent(task: task));
            },
            child: Card(
              clipBehavior: Clip.hardEdge, // Ensures ListTile edges don't overflow the Card
              surfaceTintColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(mq.width * .02),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .008),
                tileColor: const Color(0xFF111111),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task!.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: mq.width * .02), // Add some space between the title and email
                    Text(
                      task.assignedTo,
                      style: TextStyle(
                        fontSize: mq.width *.03,
                          color: Colors.white70),
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    SizedBox(height: mq.height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getStatusColor(task.status), // Function to determine the color based on task status
                          ),
                          width: mq.width * .05,
                          height: mq.width * .05,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

  } else if (state is ProjectDetailsLoadingState) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.greenAccent,
      )
    );
  }
  return const Center(
    child: Text(
      'No Tasks added.',
      style: TextStyle(color: Colors.white70),
    ),
  );
}

void _showDeleteConfirmationDialog(BuildContext parentContext, Projects project, HomeBloc homeBloc) {
  showDialog(
    context: parentContext,
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Project',
          style: TextStyle(color: Colors.white),
        ),
        content: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Are you sure you want to delete ',
                style: TextStyle(color: Colors.white70),
              ),
              TextSpan(
                text: '"${project.title}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: '?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(parentContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              // Trigger deletion
              parentContext.read<ProjectDetailsBloc>().add(ProjectDetailsDeleteBtnEvent(projectId: project.id));

              // Close the dialog
              Navigator.of(parentContext).pop();

              // Reinitialize the previous screen's HomeBloc state
              homeBloc.add(HomeInitialEvent());
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      );
    },
  );
}

void _showMemberDeleteConfirmationDialog(BuildContext parentContext, Projects project, TeamMember member) {
  showDialog(
    context: parentContext,
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Remove Member',
          style: TextStyle(color: Colors.white),
        ),
        content: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Are you sure you want to remove ',
                style: TextStyle(color: Colors.white70),
              ),
              TextSpan(
                text: '"${member.name}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: '?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(parentContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Add action for removing member
              parentContext.read<ProjectDetailsBloc>().add(ProjectDetailsRemoveMemberEvent(member: member, project: project));
              Navigator.pop(parentContext);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      );
    },
  );
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.greenAccent;
    case 'in progress':
      return Colors.yellow;
    case 'pending':
      return Colors.red;
    default:
      return Colors.grey; // Default color if no match
  }
}
