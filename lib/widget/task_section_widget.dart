import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl package for date formatting
import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/model/sf_task_model.dart';
import 'package:threedaysplanner/util/sf_util.dart';
import 'package:threedaysplanner/util/util.dart';
import 'package:threedaysplanner/widget/task_widget.dart';

class TaskSectionWidget extends StatefulWidget {
  final String title;
  final String date;
  final List<AppTaskModel> tasks; // Updated to use AppTaskModel directly

  const TaskSectionWidget({
    super.key,
    required this.title,
    required this.date,
    required this.tasks,
  });

  @override
  State<TaskSectionWidget> createState() => _TaskSectionWidgetState();
}

class _TaskSectionWidgetState extends State<TaskSectionWidget> {
  final Set<String> completedTasks = {};

  @override
  void initState() {
    super.initState();

    // Populate completedTasks with tasks that have a status of "Completed"
    for (var task in widget.tasks) {
      if (task.status == 'Completed') {
        completedTasks.add(task.id);
      }
    }
  }

  Future<void> onTaskCompleted(String taskId) async {
    AppTaskModel task = widget.tasks.firstWhere((task) => task.id == taskId);
    task.status = 'Completed'; // Update the status to "Completed"
    task.actualCompletionTime = DateTime.now().toIso8601String(); // Set the actual completion time

    SalesforceTaskModel sfTask = SalesforceTaskModel.fromAppTask(task);

    final success = await SFUtil.updateTask(sfTask);

    if (success) {
      print('Task marked as completed successfully.');
    } else {
      print('Failed to mark task as completed.');
    }
  }

  Future<void> onTaskNotCompleted(String taskId) async {
    AppTaskModel task = widget.tasks.firstWhere((task) => task.id == taskId);
    task.status = 'Not Started'; // Update the status to "Not Started"
    task.actualCompletionTime = null; // Reset the actual completion time

    SalesforceTaskModel sfTask = SalesforceTaskModel.fromAppTask(task);

    final success = await SFUtil.updateTask(sfTask);

    if (success) {
      print('Task marked as not completed successfully.');
    } else {
      print('Failed to mark task as not completed.');
    }
  }

  Future<void> onTaskUpdated(AppTaskModel task) async {
    SalesforceTaskModel sfTask = SalesforceTaskModel.fromAppTask(task);
    print('sfTask inside onTaskUpdated => ${sfTask.name}');
    final success = await SFUtil.updateTask(sfTask);

    if (success) {
      print('Task updated successfully.');
    } else {
      print('Failed to update task.');
    }
  }

  Future<bool> onTaskDelete(String taskId) async {
    
    final success = await SFUtil.deleteTask(taskId);

    if (success) {
      print('Task is deleted successfully.');
      return true;
    } 
    else {
      print('Failed to delete task.');
      return false;
    }
  }

  String formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime); // Parse the ISO 8601 string
      return DateFormat.jm().format(dateTime); // Format as 10:30 AM or 12:55 PM
    } catch (e) {
      return 'Invalid Time'; // Fallback in case of parsing errors
    }
  }

  void showEditTaskDialog(AppTaskModel task) {
    final TextEditingController taskNameController = TextEditingController(text: task.name);
    String selectedPriority = task.priority; // Track the selected priority

    // Get the other two priorities
    final List<String> priorities = ['High', 'Medium', 'Low'];
    final List<String> otherPriorities = priorities.where((p) => p != task.priority).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  // Task Name Field
                  TextField(
                    controller: taskNameController,
                    decoration: const InputDecoration(labelText: 'Task Name'),
                  ),
                  const SizedBox(height: 12),

                  // Priority Section
                  const Text('Priority'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
                    children: otherPriorities.map((priority) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: priority,
                            groupValue: selectedPriority,
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPriority = value!;
                              });
                            },
                          ),
                          Text(priority), // Display the other priority options
                          const SizedBox(width: 16), // Add spacing between choices
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  // Update the task name and priority
                  task.name = taskNameController.text;
                  task.priority = selectedPriority;
                });
                await onTaskUpdated(task); // Call the async method
                Navigator.of(context).pop(); // Close the dialog after saving
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            widget.date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            Util.getDayOfWeek(widget.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Util.isWeekend(widget.date) ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...tasks.map((task) {
        final isCompleted = completedTasks.contains(task.id);

        return TaskWidget(
          task: task,
          onUndo: (deletedTask) {
            setState(() {
              // Use the stored original index to re-add the task
              widget.tasks.insert(deletedTask.originalIndex ?? 0, deletedTask);
              completedTasks.remove(deletedTask.id); // Remove from completed tasks if necessary
            });
          },
          isCompleted: isCompleted,
          onCompletionChanged: (bool? value) async {
            if (value == true) {
              setState(() {
                completedTasks.add(task.id);
              });
              await onTaskCompleted(task.id);
            } else {
              setState(() {
                completedTasks.remove(task.id);
              });
              await onTaskNotCompleted(task.id);
            }
          },
          onEdit: () {
            showEditTaskDialog(task);
          },
          onDelete: () async {
            final originalIndex = widget.tasks.indexOf(task); // Get the original index
            final success = await onTaskDelete(task.id);
            if (success) {
              setState(() {
                widget.tasks.removeAt(originalIndex); // Remove the task from its original position
              });
              // Attach the original index to the task for undo purposes
              task.originalIndex = originalIndex;
            }
            return success;
          },
        );
      }).toList(),
      const SizedBox(height: 16),
    ],
  );
}
}