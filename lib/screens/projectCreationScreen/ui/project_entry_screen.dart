import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For formatting the selected date
import 'package:scuffed_collab/helper/dailogs.dart';
import 'package:scuffed_collab/screens/projectCreationScreen/ui/teamMember_entry_screen.dart';
import 'package:scuffed_collab/widgets/TextFieldWidget.dart';
import '../../../main.dart';
import '../projectCreationBloc/project_bloc.dart';

class ProjectEntryScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  String deadlineText = 'Select Project Deadline';

  ProjectEntryScreen({super.key});

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Dispatch the event to update the deadline in the Bloc
      context.read<ProjectBloc>().add(
          ProjectDeadlineSelectedEvent(deadline: dateFormat.format(picked)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listenWhen: (previous, current) => current is ProjectActionState,
      buildWhen: (previous, current) => current is! ProjectActionState,
      listener: (context, state) {
        if (state is ProjectSubmittedState) {
          log('Project Submitted State Fired');
          Navigator.push(context, MaterialPageRoute(builder: (_)=> BlocProvider.value(
            value: context.read<ProjectBloc>(),
            child: TeamMemberEntryScreen(
              projectTitle: state.title,
              projectDescription: state.description,
              projectDeadline: state.deadline
            ),
          )
          ));
        } else if (state is ProjectIncompleteDetailsSubmittedState) {
          Dialogs.showSnackBar(context, state.message);
        } else if (state is ProjectErrorState) {
          Dialogs.showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        final projectBloc = context.read<ProjectBloc>();

        // Initialize text controllers with the current title and description from the BLoC
        titleController.text = projectBloc.title;
        descriptionController.text = projectBloc.description;

        return Scaffold(
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
            title: const Text(
              'Create Project',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(mq.width * .1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Title Field
                    Center(
                      child: RoundedTextField(
                        padding: EdgeInsets.symmetric(
                            horizontal: mq.width * .05,
                            vertical: mq.height * .014),
                        fillColor: const Color(0xFF3c3c3c),
                        borderColor: const Color(0xFF1e1e1e),
                        width: mq.width * .8,
                        height: mq.height * .055,
                        controller: titleController,
                        labelText: 'Project Title',
                        onChanged: (value) {
                          projectBloc.add(ProjectTitleChangedEvent(title: value));
                        },
                      ),
                    ),

                    SizedBox(
                      height: mq.height * .04,
                    ),
                    // Project Description Field
                    Center(
                      child: RoundedTextField(
                        padding: EdgeInsets.symmetric(
                            horizontal: mq.width * .05,
                            vertical: mq.height * .014),
                        fillColor: const Color(0xFF3c3c3c),
                        borderColor: const Color(0xFF1e1e1e),
                        width: mq.width * .8,
                        height: mq.height * .055,
                        controller: descriptionController,
                        labelText: 'Project Description',
                        onChanged: (value) {
                          projectBloc.add(ProjectDescriptionChangedEvent(description: value));
                        },
                      ),
                    ),
                    SizedBox(
                      height: mq.height * .04,
                    ),

                    // Deadline Selection
                    BlocBuilder<ProjectBloc, ProjectState>(
                      builder: (context, state) {
                        if (state is ProjectDeadlineSubmittedState) {
                          deadlineText = state.deadline;
                        }

                        return Center(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: mq.width * .05,
                                vertical: mq.height * .014,
                              ),
                              width: mq.width * .8,
                              height: mq.height * .055,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3c3c3c),
                                borderRadius: BorderRadius.circular(30),
                                border:
                                Border.all(color: const Color(0xFF1e1e1e)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    deadlineText,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: mq.width * .04),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.greenAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: mq.height * .12),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text;
                          final description = descriptionController.text;

                          if (title.isNotEmpty && description.isNotEmpty && deadlineText != 'Select Project Deadline') {
                            context.read<ProjectBloc>().add(
                              ProjectDetailsSubmittedEvent(
                                title: title,
                                deadline: deadlineText,
                                description: description,
                              ),
                            );
                            log('Deadline $deadlineText');
                          } else {
                            context.read<ProjectBloc>().add(
                              ProjectIncompleteDetailsSubmittedEvent(),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              const Color(0xFF111111)),
                          fixedSize: WidgetStateProperty.all(
                              Size(mq.width * .7, mq.height * .07)),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: mq.width * .045,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
