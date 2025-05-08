import 'package:intl/intl.dart';

class DataGenerator {
  static Future<Map<String, dynamic>> getMockTaskData({int count = 10}) async {
    Future.delayed(const Duration(seconds: 1)); // Simulate API delay

    final now = DateTime.now();
    final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
    final today = DateFormat('yyyy-MM-dd').format(now);
    final tomorrow = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    final response = {
      "totalSize": 6,
      "done": true,
      "records": [
        // Tasks for yesterday
        {
          "attributes": {
            "type": "Work__c",
            "url": "/services/data/v52.0/sobjects/Work__c/1001"
          },
          "Id": "1001",
          "Name": "Fix the plumbing",
          "Tentative_Completion_Time__c": "${yesterday}T09:00:00.000Z",
          "Actual_Completion_Time__c": "${yesterday}T11:00:00.000Z",
          "Priority__c": "High",
          "Category__c": "Personal",
          "Reminder_Required__c": true,
          "Status__c": "Completed",
          "Missed__c": false,
          "Number_Of_Times_Missed__c": 0,
          "Snoozed__c": false
        },
        {
          "attributes": {
            "type": "Work__c",
            "url": "/services/data/v52.0/sobjects/Work__c/1002"
          },
          "Id": "1002",
          "Name": "Prepare presentation",
          "Tentative_Completion_Time__c": "${yesterday}T14:00:00.000Z",
          "Actual_Completion_Time__c": "${yesterday}T16:00:00.000Z",
          "Priority__c": "Medium",
          "Category__c": "Work",
          "Reminder_Required__c": false,
          "Status__c": "Completed",
          "Missed__c": false,
          "Number_Of_Times_Missed__c": 0,
          "Snoozed__c": false
        },

        // Tasks for today
        {
          "attributes": {
            "type": "Work__c",
            "url": "/services/data/v52.0/sobjects/Work__c/2001"
          },
          "Id": "2001",
          "Name": "Team meeting",
          "Tentative_Completion_Time__c": "${today}T10:00:00.000Z",
          "Actual_Completion_Time__c": "${today}T11:30:00.000Z",
          "Priority__c": "High",
          "Category__c": "Work",
          "Reminder_Required__c": true,
          "Status__c": "In Progress",
          "Missed__c": false,
          "Number_Of_Times_Missed__c": 0,
          "Snoozed__c": false
        },
        {
          "attributes": {
            "type": "Work__c",
            "url": "/services/data/v52.0/sobjects/Work__c/2002"
          },
          "Id": "2002",
          "Name": "Doctor appointment",
          "Tentative_Completion_Time__c": "${today}T13:00:00.000Z",
          "Actual_Completion_Time__c": "${today}T14:00:00.000Z",
          "Priority__c": "Medium",
          "Category__c": "Personal",
          "Reminder_Required__c": true,
          "Status__c": "Completed",
          "Missed__c": false,
          "Number_Of_Times_Missed__c": 0,
          "Snoozed__c": false
        },

        // Tasks for tomorrow
        {
          "attributes": {
            "type": "Work__c",
            "url": "/services/data/v52.0/sobjects/Work__c/3001"
          },
          "Id": "3001",
          "Name": "Submit project report",
          "Tentative_Completion_Time__c": "${tomorrow}T09:00:00.000Z",
          "Actual_Completion_Time__c": "${tomorrow}T11:00:00.000Z",
          "Priority__c": "High",
          "Category__c": "Work",
          "Reminder_Required__c": true,
          "Status__c": "Not Started",
          "Missed__c": false,
          "Number_Of_Times_Missed__c": 0,
          "Snoozed__c": false
        },
        {
          "attributes": {
            "type": "Work__c",
            "url": "/services/data/v52.0/sobjects/Work__c/3002"
          },
          "Id": "3002",
          "Name": "Plan weekend trip",
          "Tentative_Completion_Time__c": "${tomorrow}T14:00:00.000Z",
          "Actual_Completion_Time__c": "${tomorrow}T16:00:00.000Z",
          "Priority__c": "Medium",
          "Category__c": "Personal",
          "Reminder_Required__c": false,
          "Status__c": "Not Started",
          "Missed__c": false,
          "Number_Of_Times_Missed__c": 0,
          "Snoozed__c": false
        }
      ]
    };
    return Future.value(response);
  }
}