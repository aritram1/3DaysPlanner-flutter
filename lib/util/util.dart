import 'dart:math';
import 'package:intl/intl.dart';
import 'package:threedaysplanner/data/data.dart';
import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/model/sf_task_model.dart';
import 'package:threedaysplanner/util/sf_util.dart';

class Util {

  static Future<List<SalesforceTaskModel>> getTaskData() async {

    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    // Mock Salesforce response
    // Map<String, dynamic> response = await DataGenerator.getMockTaskData();

    // Actual code
    Map<String, dynamic> response = await SFUtil.getTaskData();
    
    List<SalesforceTaskModel> tasks = [];
    List<dynamic> data = response['records'] as List<dynamic>;    
    for (final task in data) {
      tasks.add(SalesforceTaskModel.fromMap(task as Map<String, dynamic>));
    }

    return Future.value(tasks);
  }

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
      } 
      else if (taskDateOnly.isAtSameMomentAs(tomorrow)) {
        groupedTasks['tomorrow']!.add(appTask);
      } 
      else if (taskDateOnly.isAfter(tomorrow)) {
        groupedTasks['later']!.add(appTask); // Assign tasks beyond tomorrow to "Later"
      }
    }

    // Return the transformed data
    return groupedTasks;
  }


  // Helper method to get the month name
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

  static String getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  // Format issuedAt if available from time in miliseconds to Date time
  static String getTimeDifference(DateTime issuedAtDateTime) {
    
    final now = DateTime.now();
    final durationAgo = now.difference(issuedAtDateTime);
    String timeDiff = '';
    if (durationAgo.inDays > 0) {
      timeDiff = '${durationAgo.inDays} days ago';
    } 
    else if (durationAgo.inHours > 0) {
      timeDiff = '${durationAgo.inHours} hours ago';
    } 
    else if (durationAgo.inMinutes > 0) {
      timeDiff = '${durationAgo.inMinutes} minutes ago';
    } 
    else {
      timeDiff = 'just now';
    }
    return timeDiff;
  }


  static String getDayOfWeek(String date) {
    try {
      final parsedDate = DateFormat('d MMMM yyyy').parse(date); // Parse the date string
      return DateFormat('EEEE').format(parsedDate); // Format as full day name (e.g., Monday)
    } catch (e) {
      return ''; // Return an empty string if parsing fails
    }
  }

  static bool isWeekend(String date) {
    try {
      final parsedDate = DateFormat('d MMMM yyyy').parse(date); // Parse the date string
      final dayOfWeek = parsedDate.weekday; // Get the day of the week (1 = Monday, 7 = Sunday)
      return dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday; // Check if it's Saturday or Sunday
    } catch (e) {
      return false; // Return false if parsing fails
    }
  }
}