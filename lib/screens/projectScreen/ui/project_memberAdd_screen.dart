import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scuffed_collab/screens/projectScreen/projectBloc/project_details_bloc.dart';
import '../../../helper/dailogs.dart';
import '../../../main.dart';
import '../../../models/ProjectsModel.dart';
import '../../../models/TeamModel.dart';
import '../../../widgets/TextFieldWidget.dart';

class TeamMemberAddScreen extends StatelessWidget {
  final Projects project;

  // Add a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TeamMemberAddScreen({super.key, required this.project});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectDetailsBloc, ProjectDetailsState>(
      listenWhen: (previous, current) => current is ProjectDetailsActionState,
      buildWhen: (previous, current) => current is! ProjectDetailsActionState,
      listener: (context, state) {
        if (state is ProjectTeamMemberAdded) {
          // Show success message
          Dialogs.showSnackBar(context, 'Team member added ${state.email}');
        } else if (state is ProjectTeamMemberNotExistState) {
          Dialogs.showSnackBar(context, 'User Does Not Exist');
        } else if (state is ProjectMemberAlreadyExistsState) {
          Dialogs.showSnackBar(context, 'Member already exists');
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            key: _scaffoldKey, // Assign the Scaffold key here
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  // Reinitialize previous screen
                  context.read<ProjectDetailsBloc>().add(
                    ProjectDetailsInitialEvent(project: project),
                  );
                  Navigator.pop(context);
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
                      // Add Project Member
                      final email = emailController.text;
                      context.read<ProjectDetailsBloc>().add(ProjectDetailsMemberAddedEvent(
                          project:project ,email: email));
                      emailController.clear();
                    },
                    child: Text(
                      'Add Member',
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
                    hintText: 'Enter Email',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
