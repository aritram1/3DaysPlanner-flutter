import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:threedaysplanner/model/sf_task_model.dart';
import 'package:threedaysplanner/util/app_constants.dart'; // Import app constants
import 'package:threedaysplanner/util/auth.dart';
import 'package:threedaysplanner/util/secure_file_manager.dart'; // Import SalesforceAuth for access token
import 'package:threedaysplanner/model/app_task_model.dart';

class SFUtil {

  // Method 1: Get Task Data from Work__c Object
  static Future<Map<String, dynamic>> getTaskData() async {
    
    // bool auth = await isAuthenticated();

    // Early exit in case of unauthenticated scenario
    if (SalesforceAuth.accessToken == null) {
      // Attempt to authenticate if the access token is null
      final authenticated = await SalesforceAuth.authenticate();
      if (!authenticated) {
        throw Exception('Authentication failed. Unable to fetch task data.');
      }
    }

    Map<String, dynamic> response = {};
    final url = Uri.parse('${AppConstants.instanceUrl}/services/data/v52.0/query');
    const query = '''SELECT Id, Name, Tentative_Completion_Time__c, Actual_Completion_Time__c,
                      Priority__c, Category__c, Reminder_Required__c, 
                      Status__c, Missed__c, Number_Of_Times_Missed__c, Snoozed__c 
                      FROM Work__c''';

    // const query = '''SELECT Id, Name, Tentative_Completion_Time__c, Actual_Completion_Time__c,
    //                   Priority__c, Category__c, Reminder_Required__c, 
    //                   Status__c, Missed__c, Number_Of_Times_Missed__c, Snoozed__c 
    //                   FROM Work__c
    //                   WHERE Tentative_Completion_Time__c = YESTERDAY 
    //                     OR Tentative_Completion_Time__c = TODAY 
    //                     OR Tentative_Completion_Time__c = TOMORROW
    //                   ORDER BY Tentative_Completion_Time__c ASC
    //               ''';

    final sfResponse = await http.get(
      url.replace(queryParameters: {'q': query}),
      headers: {
        'Authorization': 'Bearer ${SalesforceAuth.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (sfResponse.statusCode == 200 || sfResponse.statusCode == 201) {
      print('sfResponse.body status 200=>${sfResponse.body}');
      // Parse the response body
      response = jsonDecode(sfResponse.body) as Map<String, dynamic>;
      return response;
    } 
    else {
      print('Failed to fetch task data: ${sfResponse.body}');
      throw Exception('Failed to fetch task data');
    }
  }

  /// Method 2: Save Task Data to Work__c Object
  // static Future<bool> saveTaskData(Map<String, dynamic> task) async {
  //   if (SalesforceAuth.accessToken == null) {
  //     // Attempt to authenticate if the access token is null
  //     final authenticated = await SalesforceAuth.authenticate();
  //     if (!authenticated) {
  //       throw Exception('Authentication failed. Unable to save task data.');
  //     }
  //   }

  //   final url = Uri.parse('${AppConstants.instanceUrl}/services/data/v52.0/sobjects/Work__c');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer ${SalesforceAuth.accessToken}',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(task),
  //   );

  //   if (response.statusCode == 201) {
  //     print('Task saved successfully: ${response.body}');
  //     return true;
  //   } else {
  //     print('Failed to save task: ${response.body}');
  //     return false;
  //   }
  // }

  /// Method 2: Save Task Data to Work__c Object
  static Future<Map<String, dynamic>> saveTaskToSalesforce(Map<String, dynamic> task) async {  
    
    Map<String, dynamic> returnValue = {};
    
    // bool auth = await isAuthenticated();

    // Early exit in case of unauthenticated scenario
    if (SalesforceAuth.accessToken == null) {
      // Attempt to authenticate if the access token is null
      final authenticated = await SalesforceAuth.authenticate();
      if (!authenticated) {
        throw Exception('Authentication failed. Unable to save task to Salesforce.');
      }
    }

    final url = Uri.parse('${AppConstants.instanceUrl}/services/data/v52.0/sobjects/Work__c');
    print('url insde saveTaskToSalesforce=> $url');
    print('Task inside saveTaskToSalesforce=> ${jsonEncode(task)}');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SalesforceAuth.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task),
    );

    if (response.statusCode == 201) {
      String responseBody = response.body;
      print('Task successfully saved to Salesforce: $responseBody');
      returnValue['success'] = true;
      returnValue['message'] = responseBody;
    } 
    else {
      String errorMessage = 'Failed to save task to Salesforce: ${response.body}';
      print('errorMessage => $errorMessage');
      returnValue['success'] = false;
      returnValue['message'] = errorMessage;
    }
    return Future.value(returnValue);
  }
  
  static Future<bool> updateTask(SalesforceTaskModel task) async {

    final url = Uri.parse('${AppConstants.instanceUrl}/services/data/v52.0/sobjects/Work__c/${task.id}');

    print('URL inside the updateTask() =>$url');

    final taskData = task.toMap();
    taskData.remove('Id'); // Remove the Id field from the request body
    print('taskData inside updateTask() => $taskData');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer ${SalesforceAuth.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task updated successfully: ${response.body}');
        // Task updated successfully
        return true;
      } else {
        print('Failed to update task: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  static Future<bool> deleteTask(String taskId) async {
    final url = Uri.parse('${AppConstants.instanceUrl}/services/data/v52.0/sobjects/Work__c/$taskId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${SalesforceAuth.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        print('Task deleted successfully.');
        return true;
      } 
      else {
        print('Failed to delete task: ${response.body}');
        return false;
      }
    } 
    catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // To be checked later to optimize login sessions
  static Future<bool> isAuthenticated() async{
    final authInfo = await SecureFileManager.getAuthInfo();
    String? accessToken = authInfo?['access_token'];
    return (accessToken != null && accessToken.isNotEmpty);
  }
  
}