import 'package:flutter/material.dart';
import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/util/util.dart';

class TaskWidget extends StatelessWidget {
  final AppTaskModel task;
  final bool isCompleted;
  final Function(bool?) onCompletionChanged;
  final Function() onEdit;
  final Future<bool> Function() onDelete;
  final Function(AppTaskModel) onUndo;

  const TaskWidget({
    super.key,
    required this.task,
    required this.isCompleted,
    required this.onCompletionChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final taskName = task.name;
    final taskTime = Util.formatTime(task.tentativeCompletionTime);
    final taskDateTime = DateTime.parse(task.tentativeCompletionTime);
    final taskDate = '${Util.getMonthName(taskDateTime.month)} ${taskDateTime.day}'; // like "Jan 12"

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart, // Change to left swipe
      background: ClipRRect(
        borderRadius: BorderRadius.circular(12), // Match the card's border radius
        child: Container(
          color: Colors.red,
          alignment: Alignment.centerRight, // Align delete icon to the right
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (direction) async {
        final deletedTask = task; // Temporarily store the deleted task
        final success = await onDelete();

        if (success) {
          // Show a SnackBar with an "Undo" action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Restore the task if "Undo" is clicked
                  onUndo(deletedTask);
                },
              ),
              duration: const Duration(seconds: 5), // Duration before the SnackBar disappears
            ),
          );
        } else {
          // Show an error SnackBar if deletion fails
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete task.')),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Ensure the card has the same border radius
        ),
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