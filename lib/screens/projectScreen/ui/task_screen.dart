import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scuffed_collab/helper/dailogs.dart';
import 'package:scuffed_collab/models/TaskModel.dart';
import 'package:scuffed_collab/screens/projectScreen/projectBloc/project_details_bloc.dart';

import '../../../main.dart';
import '../../../models/ProjectsModel.dart';

class TaskScreen extends StatelessWidget {
  final Projects project;
  final TaskModel task;

  const TaskScreen({super.key, required this.task, required this.project});

  @override
  Widget build(BuildContext context) {
    String status = task.status;

    return BlocConsumer<ProjectDetailsBloc, ProjectDetailsState>(
      listenWhen: (previous, current) => current is ProjectDetailsActionState,
      buildWhen: (previous, current) => current is! ProjectDetailsActionState,
      listener: (context, state) {
        // TODO: implement listener
        if (state is TaskStatusUpdatedNavBackBtnState){
          Navigator.pop(context);
        } else if (state is ProjectDetailsErrorState){
          Dialogs.showSnackBar(context, state.error);
        } else if (state is TaskDeleteBtnNavState){
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
               context.read<ProjectDetailsBloc>().add(TaskScreenStatusChangedEvent(projectId: project.id,
                   taskId: task.id, status: status));
               //Reinitialize previous screen
               context.read<ProjectDetailsBloc>().add(ProjectDetailsInitialEvent(project: project ));

              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: mq.width * .05,
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(mq.width * .04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned To:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: mq.width * .045),
                ),
                SizedBox(height: mq.height * .015),
                Text(
                  task.assignedTo,
                  style: TextStyle(
                      color: Colors.white70, fontSize: mq.width * .04),
                ),
                SizedBox(height: mq.height * .02),
                Text(
                  'Description:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: mq.width * .045),
                ),
                SizedBox(height: mq.width * .015),
                Text(
                  task.description,
                  style: TextStyle(
                      color: Colors.white70, fontSize: mq.width * .04),
                ),
                SizedBox(height: mq.height * .02),

                // Task Status
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: mq.width *.045,
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),

                SizedBox(height: mq.height * .015),

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
                        underline: SizedBox.shrink(),
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
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
            backgroundColor: const Color(0xFF111111),
            icon: const Icon(
              Icons.close,
              color: Colors.greenAccent,
            ),
            label: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: mq.width * .04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Task',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                // Use parentContext instead of dialogContext here
                parentContext.read<ProjectDetailsBloc>().add(
                  TaskDeleteBtnEvent(
                    projectId: project.id,
                    taskId: task.id,
                  ),
                );

                // Reinitialize previous screen
                parentContext.read<ProjectDetailsBloc>().add(
                  ProjectDetailsInitialEvent(project: project),
                );

                Navigator.of(dialogContext).pop(); // Close the dialog
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
}
