import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scuffed_collab/helper/dailogs.dart';
import 'package:scuffed_collab/screens/projectCreationScreen/projectCreationBloc/project_bloc.dart';
import 'package:scuffed_collab/screens/projectScreen/projectBloc/project_details_bloc.dart';
import 'package:scuffed_collab/widgets/TextFieldWidget.dart';

import '../../../main.dart';
import '../../../models/ProjectsModel.dart';
import '../../../models/TeamModel.dart';

class CreateTaskScreen extends StatelessWidget {
  final List<TeamMember?> teamMembers;
  final Projects project;
  const CreateTaskScreen({
    Key? key,
    required this.teamMembers, required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedAssignedTo =
        teamMembers.isNotEmpty ? teamMembers.first!.email : '';
    String status = 'Pending';
    String deadlineText = 'Select Task Deadline';
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');


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
        // context.read<ProjectBloc>().add(
        //     ProjectDeadlineSelectedEvent(deadline: dateFormat.format(picked)));
        context.read<ProjectDetailsBloc>().add(
            TaskDeadlineSelectedEvent(deadline: dateFormat.format(picked)));
      }
    }

    log(selectedAssignedTo);
    return BlocConsumer<ProjectDetailsBloc, ProjectDetailsState>(
      listener: (context, state) {
        // TODO: implement listener
        if(state is ProjectDetailsCreateTaskNavState){
          Navigator.pop(context);
        } else if (state is ProjectDetailsErrorState){
          Dialogs.showSnackBar(context, state.error);
        } else if (state is TaskEmptyFieldsState){
          Dialogs.showSnackBar(context, 'Fill All fields');
        }
      },
      builder: (context, state) {
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
              'Add Task',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  // Task Title
                  const Text(
                    'Task Title',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  RoundedTextField(
                    width: mq.width * .8,
                    height: mq.height * .05,
                    controller: titleController,
                    fillColor: const Color(0xFF3c3c3c),
                    borderColor: const Color(0xFF1e1e1e),
                    hintColor: Colors.white70,
                    hintText: 'Task Title',
                    padding: EdgeInsets.symmetric(
                        horizontal: mq.width * .04, vertical: mq.height * .014),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
            
                  // Task Description
                  const Text(
                    'Task Description',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
            
                  SizedBox(
                    height: mq.height * .02,
                  ),
            
                  RoundedTextField(
                    width: mq.width * .8,
                    height: mq.height * .05,
                    controller: descriptionController,
                    fillColor: const Color(0xFF3c3c3c),
                    borderColor: const Color(0xFF1e1e1e),
                    hintColor: Colors.white70,
                    hintText: 'Task Description',
                    padding: EdgeInsets.symmetric(
                        horizontal: mq.width * .04, vertical: mq.height * .014),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
            
                  // Assigned To
                  const Text(
                    'Assigned To',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),

                  //Assigned To
                  BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
                    builder: (context, state) {
                      if (state is TaskAssignedChangedState) {
                        selectedAssignedTo = state.email;
                      }
                      return Container(
                        height: mq.height * .05,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(mq.width * .04),
                            color: const Color(0xFF3c3c3c)),
                        child: DropdownButton<String>(
                          underline: const SizedBox.shrink(),
                          padding:
                              EdgeInsets.symmetric(horizontal: mq.width * .04),
                          style: TextStyle(
                            fontSize: mq.width * .04,
                            color: Colors.white,
                          ),
                          icon: Transform.rotate(
                              angle: 3 * 3.14 / 2,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.greenAccent,
                                size: mq.width *.055,
                              )),
                          value:
                              selectedAssignedTo, // Display the selected value as the current value
                          isExpanded: true,
                          items: teamMembers
                              .map((member) {
                            return DropdownMenuItem<String>(
                              value: member!.email,
                              child: Text(member.email),
                            );
                          }).toList(),

                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              selectedAssignedTo =
                                  newValue; // Update the selected value when a new option is selected
                              context.read<ProjectDetailsBloc>().add(
                                  TaskAssignedChangeEvent(
                                      email: selectedAssignedTo));
                            }
                          },
                          hint: Text(
                              selectedAssignedTo ??
                                  'Select a team member', // Show selected item as initial value
                              style: const TextStyle(color: Colors.white)),
                          dropdownColor:
                              const Color(0xFF3c3c3c), // Match dropdown color
                        ),
                      );
                    },
                  ),
            
                  SizedBox(height: mq.height *.02),
            
                  // Task Status
                  const Text(
                    'Status',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
            
                  SizedBox(height: mq.height *.02),
            
                  BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
                    builder: (context, state) {
                      if (state is TaskStatusChangedState) {
                        status = state.status;
                      }
                      return Container(
                        height: mq.height * .05,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(mq.width * .04),
                            color: const Color(0xFF3c3c3c)),
                        child: DropdownButton<String>(
                          underline: const SizedBox.shrink(),
                          style: TextStyle(
                            fontSize: mq.width * .04,
                            color: Colors.white,
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: mq.width * .04),
                          value: status, // Default value
                          isExpanded: true,
                          icon: Transform.rotate(
                              angle: 3 * 3.14 / 2,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.greenAccent,
                                size: mq.width *.055,
                              )),
                          items: const [
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'in progress',
                              child: Text('In Progress'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                          ],
                          dropdownColor:
                              const Color(0xFF3c3c3c), // Match dropdown color
                          onChanged: (String? newStatus) {
                            // Handle status change if needed
                            status = newStatus!;
                            context
                                .read<ProjectDetailsBloc>()
                                .add(TaskStatusChangeEvent(status: status));
                            log(status);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
            
                  // Deadline
                  const Text(
                    'Deadline',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
            
                  BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
                    builder: (context, state) {
                      if (state is TaskDeadlineSubmittedState) {
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
                            width: mq.width * .95,
                            height: mq.height * .055,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3c3c3c),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF1e1e1e)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            
                  SizedBox(height: mq.height * .1),
            
                  // Create Task Button
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color(0xFF111111),
                        ),
                        fixedSize: WidgetStateProperty.all(
                            Size(mq.width * .7, mq.height * .06)),
                      ),
                      onPressed: () {
                        final taskTitle = titleController.text;
                        final taskDescription = descriptionController.text;
            
                        if(taskTitle.isNotEmpty && taskDescription.isNotEmpty && deadlineText.isNotEmpty ) {
                          context.read<ProjectDetailsBloc>().add(ProjectDetailsCreateTaskEvent(
                              taskId: project.id,
                              taskTitle: taskTitle,
                              taskDescription: taskDescription,
                              taskAssigned: selectedAssignedTo,
                              taskStatus: status,
                              taskDeadline: deadlineText),
                          );
                          
                          context.read<ProjectDetailsBloc>().add(ProjectDetailsInitialEvent(project: project ));
                        } else {
                          context.read<ProjectDetailsBloc>().add(TaskEmptyFieldsEvent());
                        }
                      },
                      child: const Text(
                        'Create Task',
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
