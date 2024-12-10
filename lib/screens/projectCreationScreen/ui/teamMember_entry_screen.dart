import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../helper/dailogs.dart';
import '../../../main.dart';
import '../../../widgets/TextFieldWidget.dart';
import '../projectCreationBloc/project_bloc.dart';

class TeamMemberEntryScreen extends StatelessWidget {
  final String projectTitle;
  final String projectDescription;
  final String projectDeadline;

  // Add a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TeamMemberEntryScreen({required this.projectTitle, required this.projectDeadline, required this.projectDescription});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.read<ProjectBloc>().add(ProjectTeamMemberScreenLoadedEvent());

    return BlocConsumer<ProjectBloc, ProjectState>(
      listenWhen: (previous, current) => current is ProjectActionState,
      buildWhen: (previous, current) => current is! ProjectActionState,
      listener: (context, state) {
        if (state is ProjectTeamMemberAdded) {
          // Show success message
          Dialogs.showSnackBar(context, 'Team Member Added');
        } else if (state is ProjectBackBtnNavState){
          Navigator.pop(context);
        } else if (state is ProjectTeamMemberNotExistState) {
          Dialogs.showSnackBar(context, 'User Does Not Exist');
        } else if (state is ProjectMemberAlreadyExistsState) {
          Dialogs.showSnackBar(context, 'Member already exists');
        } else if (state is ProjectCreateButtonNavigationState) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false, // Removes all the previous routes
          );
        } else if (state is ProjectTeamEmptyState) {
          Dialogs.showSnackBar(context, 'Add a team member to create a project');
        } else if (state is ProjectErrorState) {
          Dialogs.showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey, // Assign the Scaffold key here
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                context.read<ProjectBloc>().add(ProjectBackBtnEvent());
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: mq.width * .05,
              ),
            ),
            title: const Text(
              'Add Team Members',
              style: TextStyle(color: Colors.white),
            ),
          ),
          floatingActionButton: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: mq.width * .08, bottom: mq.height * .03),
              child: SizedBox(
                width: mq.width * .6,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(mq.width * .08),
                  ),
                  backgroundColor: const Color(0xFF111111),
                  onPressed: () {
                    // Create Project
                    context.read<ProjectBloc>().add(ProjectCreateButtonEvent(
                        title: projectTitle, description: projectDescription, deadline: projectDeadline));
                  },
                  child: Text(
                    'Create Project',
                    style: TextStyle(color: Colors.greenAccent, fontSize: mq.width * .045),
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: mq.height * .04),
              Center(
                child: RoundedTextField(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .05, vertical: mq.height * .014),
                  fillColor: const Color(0xFF3c3c3c),
                  borderColor: const Color(0xFF1e1e1e),
                  width: mq.width * .8,
                  height: mq.height * .055,
                  controller: emailController,
                  labelText: 'Add team members',
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final email = emailController.text;
                    context.read<ProjectBloc>().add(ProjectMemberAddedEvent(email));
                    emailController.clear();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(const Color(0xFF111111)),
                    fixedSize: WidgetStateProperty.all(Size(mq.width * .7, mq.height * .07)),
                  ),
                  child: Text(
                    'Add Team Member',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: mq.width * .045,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildTeamMemberList(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamMemberList(ProjectState state) {
    if (state is ProjectTeamMemberAdded) {
      return ListView.builder(
        itemCount: state.members.length,
        itemBuilder: (context, index) {
          final member = state.members[index];
          return Card(
            surfaceTintColor: const Color(0xFF111111),
            margin: EdgeInsets.symmetric(vertical: mq.height * .01, horizontal: mq.width * .03),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: mq.height * .005),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(mq.width * .02)),
              tileColor: const Color(0xFF111111),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.profilePicture), // Profile picture
              ),
              title: Text(member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(member.email, style: const TextStyle(color: Colors.white70)),
            ),
          );
        },
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.width *.06),
      child: const Center(child: Text('No team members added.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70))),
    );
  }
}
