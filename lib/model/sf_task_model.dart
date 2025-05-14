import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/util/util.dart';

class SalesforceTaskModel {
  final String? id;
  final String? name;
  final String? tentativeCompletionTime;
  final String? actualCompletionTime;
  final String? priority;
  final String? category;
  final bool? reminderRequired;
  final String? status;
  final bool? missed;
  final int? numberOfTimesMissed;
  final bool? snoozed;

  SalesforceTaskModel({
    this.id,
    this.name,
    this.tentativeCompletionTime,
    this.actualCompletionTime,
    this.priority,
    this.category,
    this.reminderRequired,
    this.status,
    this.missed,
    this.numberOfTimesMissed,
    this.snoozed,
  });

  // Factory method to create a SalesforceTaskModel from a Map
  factory SalesforceTaskModel.fromMap(Map<String, dynamic> map) {
    return SalesforceTaskModel(
      id: map['Id'] as String?,
      name: map['Name'] as String?,
      tentativeCompletionTime: map['Tentative_Completion_Time__c'] != null
          ? Util.convertGMTToIST(map['Tentative_Completion_Time__c'] as String)
          : null,
      actualCompletionTime: map['Actual_Completion_Time__c'] != null
          ? Util.convertGMTToIST(map['Actual_Completion_Time__c'] as String)
          : null,
      priority: map['Priority__c'] as String?,
      category: map['Category__c'] as String?,
      reminderRequired: map['Reminder_Required__c'] as bool?,
      status: map['Status__c'] as String?,
      missed: map['Missed__c'] as bool?,
      numberOfTimesMissed: (map['Number_Of_Times_Missed__c'] is int)
          ? map['Number_Of_Times_Missed__c'] as int
          : (map['Number_Of_Times_Missed__c'] as double?)?.toInt() ?? 0,
      snoozed: map['Snoozed__c'] as bool?,
    );
  }

  // Convert SalesforceTaskModel to a Map (if needed)
  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Name': name,
      'Tentative_Completion_Time__c': tentativeCompletionTime != null
          ? Util.convertISTToGMT(tentativeCompletionTime!)
          : null,
      'Actual_Completion_Time__c': actualCompletionTime != null
          ? Util.convertISTToGMT(actualCompletionTime!)
          : null,
      'Priority__c': priority,
      'Category__c': category,
      'Reminder_Required__c': reminderRequired,
      'Status__c': status,
      'Missed__c': missed,
      'Number_Of_Times_Missed__c': numberOfTimesMissed,
      'Snoozed__c': snoozed,
    };
  }

  // Convert AppTaskModel to SalesforceTaskModel
  factory SalesforceTaskModel.fromAppTask(AppTaskModel appTask) {
    return SalesforceTaskModel(
      id: appTask.id,
      name: appTask.name,
      tentativeCompletionTime: appTask.tentativeCompletionTime,
      actualCompletionTime: appTask.actualCompletionTime,
      priority: appTask.priority,
      category: appTask.category,
      reminderRequired: appTask.reminderMapped == 'true',
      status: appTask.status,
      missed: appTask.missed,
      numberOfTimesMissed: appTask.numberOfTimesMissed,
      snoozed: appTask.snoozed,
    );
  }
}

