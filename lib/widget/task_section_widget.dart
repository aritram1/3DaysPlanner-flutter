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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: taskNameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
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
                  // Update the task name
                  task.name = taskNameController.text;
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
            final success = await onTaskDelete(task.id);
            if (success) {
              setState(() {
                widget.tasks.remove(task);
              });
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