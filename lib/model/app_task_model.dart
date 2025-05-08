import 'package:threedaysplanner/model/sf_task_model.dart';

class AppTaskModel {
  final String id;
  String name;
  final String tentativeCompletionTime;
  String? actualCompletionTime;
  String priority;
  String category;
  final String reminderMapped;
  String status;
  final bool missed;
  final int numberOfTimesMissed;
  final bool snoozed;

  AppTaskModel({
    required this.id,
    required this.name,
    required this.tentativeCompletionTime,
    required this.actualCompletionTime,
    required this.priority,
    required this.category,
    required this.reminderMapped,
    required this.status,
    required this.missed,
    required this.numberOfTimesMissed,
    required this.snoozed,
  });

  // Factory method to create an AppTaskModel from a SalesforceTaskModel
  factory AppTaskModel.fromSalesforceTask(SalesforceTaskModel sfTask) {
    return AppTaskModel(
      id: sfTask.id ?? '',
      name: sfTask.name ?? 'Unnamed Task',
      tentativeCompletionTime: sfTask.tentativeCompletionTime ?? 'No Tentative Time Provided',
      actualCompletionTime: sfTask.actualCompletionTime ?? 'No Actual Time Provided',
      priority: sfTask.priority ?? 'Medium',
      category: sfTask.category ?? 'Work',
      reminderMapped: sfTask.reminderRequired?.toString() ?? 'false',
      status: sfTask.status ?? 'Not Started',
      missed: sfTask.missed ?? false,
      numberOfTimesMissed: sfTask.numberOfTimesMissed ?? 0,
      snoozed: sfTask.snoozed ?? false,
    );
  }

  // Convert AppTaskModel to a Map (if needed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tentativeCompletionTime': tentativeCompletionTime,
      'actualCompletionTime': actualCompletionTime,
      'priority': priority,
      'category': category,
      'reminderMapped': reminderMapped,
      'status': status,
      'missed': missed,
      'numberOfTimesMissed': numberOfTimesMissed,
      'snoozed': snoozed,
    };
  }
}

