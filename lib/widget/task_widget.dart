import 'package:flutter/material.dart';
import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/util/util.dart';

class TaskWidget extends StatelessWidget {
  final AppTaskModel task;
  final bool isCompleted;
  final Function(bool?) onCompletionChanged;
  final Function() onEdit;
  final Future<bool> Function() onDelete;

  const TaskWidget({
    super.key,
    required this.task,
    required this.isCompleted,
    required this.onCompletionChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taskName = task.name;
    final taskTime = Util.formatTime(task.tentativeCompletionTime);
    final taskDateTime = DateTime.parse(task.tentativeCompletionTime);
    final taskDate = '${Util.getMonthName(taskDateTime.month)} ${taskDateTime.day}'; // like "Jan 12"

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        final success = await onDelete();
        if (!success) {
          // Optionally, show a snackbar or undo action if deletion fails
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete task.')),
          );
        }
      },
      child: Card(
        color: Util.getBackgroundColorBasedOnPriority(task.priority), // Set background color based on priority
        child: ListTile(
          onTap: onEdit,
          title: Text(
            taskName,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskDate, // Display the date
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                taskTime, // Display the time
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.reminderMapped == 'true') // Show alarm icon if reminder is set
                const Icon(Icons.alarm, color: Colors.blue),
              const SizedBox(width: 8),
              if (task.missed) // Show missed icon and count if the task is missed
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${task.numberOfTimesMissed}', // Display the missed count
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              Checkbox(
                value: isCompleted,
                onChanged: onCompletionChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}