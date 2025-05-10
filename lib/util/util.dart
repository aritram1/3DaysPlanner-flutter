import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:threedaysplanner/data/data.dart';
import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/model/sf_task_model.dart';
import 'package:threedaysplanner/util/sf_util.dart';

class Util {
  /// Fetches task data from Salesforce and returns a list of SalesforceTaskModel.
  static Future<List<SalesforceTaskModel>> getTaskData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    // Actual code
    Map<String, dynamic> response = await SFUtil.getTaskData();

    List<SalesforceTaskModel> tasks = [];
    List<dynamic> data = response['records'] as List<dynamic>;
    for (final task in data) {
      tasks.add(SalesforceTaskModel.fromMap(task as Map<String, dynamic>));
    }

    return Future.value(tasks);
  }

  /// Transforms a list of SalesforceTaskModel into a map grouped by 'today', 'tomorrow', and 'later'.
  static Map<String, List<AppTaskModel>> transformTaskData(List<SalesforceTaskModel> tasks) {
    final Map<String, List<AppTaskModel>> groupedTasks = {
      'today': [],
      'tomorrow': [],
      'later': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final sfTask in tasks) {
      final taskDate = DateTime.parse(sfTask.tentativeCompletionTime!).toLocal(); // Convert to local timezone
      final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day); // Truncate to date only
      final appTask = AppTaskModel.fromSalesforceTask(sfTask);

      if (taskDateOnly.isAtSameMomentAs(today)) {
        groupedTasks['today']!.add(appTask);
      } else if (taskDateOnly.isAtSameMomentAs(tomorrow)) {
        groupedTasks['tomorrow']!.add(appTask);
      } else if (taskDateOnly.isAfter(tomorrow)) {
        groupedTasks['later']!.add(appTask); // Assign tasks beyond tomorrow to "Later"
      }
    }

    // Return the transformed data
    return groupedTasks;
  }

  /// Returns the name of the month for a given month number (1 = January, 12 = December).
  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  /// Returns the name of the day for a given DateTime object (e.g., Monday, Tuesday).
  static String getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  /// Calculates the time difference between the current time and a given DateTime object
  /// and returns it as a human-readable string (e.g., "2 days ago").
  static String getTimeDifference(DateTime issuedAtDateTime) {
    final now = DateTime.now();
    final durationAgo = now.difference(issuedAtDateTime);
    String timeDiff = '';
    if (durationAgo.inDays > 0) {
      timeDiff = '${durationAgo.inDays} days ago';
    } else if (durationAgo.inHours > 0) {
      timeDiff = '${durationAgo.inHours} hours ago';
    } else if (durationAgo.inMinutes > 0) {
      timeDiff = '${durationAgo.inMinutes} minutes ago';
    } else {
      timeDiff = 'just now';
    }
    return timeDiff;
  }

  /// Returns the day of the week (e.g., Monday, Tuesday) for a given date string in the format 'd MMMM yyyy'.
  static String getDayOfWeek(String date) {
    try {
      final parsedDate = DateFormat('d MMMM yyyy').parse(date); // Parse the date string
      return DateFormat('EEEE').format(parsedDate); // Format as full day name (e.g., Monday)
    } catch (e) {
      return ''; // Return an empty string if parsing fails
    }
  }

  /// Checks if a given date string in the format 'd MMMM yyyy' falls on a weekend (Saturday or Sunday).
  static bool isWeekend(String date) {
    try {
      final parsedDate = DateFormat('d MMMM yyyy').parse(date); // Parse the date string
      final dayOfWeek = parsedDate.weekday; // Get the day of the week (1 = Monday, 7 = Sunday)
      return dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday; // Check if it's Saturday or Sunday
    } catch (e) {
      return false; // Return false if parsing fails
    }
  }

  /// Formats an ISO 8601 time string into a human-readable time format (e.g., 10:30 AM).
  static String formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat.jm().format(dateTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  /// Helper method to get background color based on priority
  static Color getBackgroundColorBasedOnPriority(String priority) {
    String prio = priority.toLowerCase();
    switch (prio) {
      case 'high':
        return Colors.red.shade100; // Light red for high priority
      case 'medium':
        return Colors.orange.shade100; // Light orange for medium priority
      case 'low':
        return Colors.green.shade100; // Light green for low priority
      default:
        return Colors.grey.shade200; // Default light grey for unknown priorities
    }
  }

  // static Color getBackgroundColorBasedOnPriority(String priority) {
  //   switch (priority.toLowerCase()) {
  //     case 'high':
  //       return Colors.grey.shade300; // Light red for high priority
  //     case 'medium':
  //       return Colors.grey.shade200; // Light orange for medium priority
  //     case 'low':
  //       return Colors.grey.shade100; // Light green for low priority
  //     default:
  //       return Colors.grey.shade500; // Default light grey for unknown priorities
  //   }
  // }
}