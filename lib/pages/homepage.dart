import 'package:flutter/material.dart';
import 'package:threedaysplanner/model/app_task_model.dart';
import 'package:threedaysplanner/model/sf_task_model.dart';
import 'package:threedaysplanner/util/util.dart';
import 'package:threedaysplanner/widget/new_task_widget.dart';
import 'package:threedaysplanner/widget/task_section_widget.dart';
import 'package:threedaysplanner/util/auth.dart'; // Import for access token
import 'package:threedaysplanner/util/app_constants.dart'; // Import for instance URL
import 'package:threedaysplanner/util/secure_file_manager.dart'; // Import for SecureFileManager

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Future to hold the task data fetched from Salesforce
  late Future<Map<String, List<AppTaskModel>>> taskData;

  @override
  void initState() {
    super.initState();
    // Fetch task data when the widget is initialized
    taskData = fetchTaskData();
  }

  // Fetch and transform task data
  Future<Map<String, List<AppTaskModel>>> fetchTaskData() async {
    
    // Fetch raw data from Salesforce and convert to List of `SalesforceTaskModel`
    List<SalesforceTaskModel> rawData = await Util.getTaskData();

    // Transform the `SalesforceTaskModel` list to day wise `AppTaskModel` list 
    // Organize as per `yesterday`, `today` and `tomorrow`
    Map<String, List<AppTaskModel>> transformedData = Util.transformTaskData(rawData);
    
    return transformedData;
  }

  // Refresh task data when the user pulls down to refresh
  Future<void> refreshTaskData() async {
    setState(() {
      taskData = fetchTaskData(); // Re-fetch task data
    });
    await taskData; // Wait for the data to be fetched
  }

  // Show dialog with Salesforce info
  void showSalesforceInfoDialog() async {
    // Fetch authentication info from SecureFileManager
    final authInfo = await SecureFileManager.getAuthInfo();

    // Extract values from the authInfo map
    final instanceUrl = authInfo?['instance_url'] ?? 'Not Available';
    final accessToken = authInfo?['access_token'] ?? 'Not Available';
    final issuedAt = authInfo?['issued_at'] ?? 'Not Available';
    print('Issued At : $issuedAt');
    String issuedAtFormatted = 'Not Available';

    if (issuedAt != 'Not Available') {
      final issuedAtDateTime = DateTime.fromMillisecondsSinceEpoch(int.tryParse(issuedAt) ?? 0);
      final durationAgoFormatted = Util.getTimeDifference(issuedAtDateTime);
      print('Issued At DateTime: $issuedAtDateTime');
      issuedAtFormatted = '${issuedAtDateTime.toLocal()} ($durationAgoFormatted)';
    }

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salesforce Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ensures the column takes up minimum space
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
            children: [
              Text('Instance URL: $instanceUrl'),
              const SizedBox(height: 8),
              Text('Access Token: $accessToken'),
              const SizedBox(height: 8),
              Text('Issued At: $issuedAtFormatted'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title), // Display the app title
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh icon
            onPressed: refreshTaskData, // Call refreshTaskData on click
          ),
          IconButton(
            icon: const Icon(Icons.key), // Key icon
            onPressed: showSalesforceInfoDialog, // Show dialog on click
          ),
          IconButton(
            icon: const Icon(Icons.add), // Add task button
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewTaskWidget(),
                ),
              );

              // Check the result and refresh the task list if a task was created
              if (result == true) {
                refreshTaskData(); // Call the method to refresh the task list
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshTaskData, // Refresh task data on pull-down
        child: FutureBuilder<Map<String, List<AppTaskModel>>>(
          future: taskData, // Fetch task data
          builder: (context, snapshot) {
            // Show a loading indicator while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Show an error message if an error occurs
            else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } 
            // Display the task data if available
            else if (snapshot.hasData) {
              final data = snapshot.data!;

              // Show a message if no tasks are available
              if (data.isEmpty) {
                return const Center(child: Text('No tasks available.'));
              }

              // Get formatted dates for today and tomorrow
              final today = DateTime.now();
              final tomorrow = today.add(const Duration(days: 1));

              final todayFormatted = '${today.day} ${Util.getMonthName(today.month)} ${today.year}';
              final tomorrowFormatted = '${tomorrow.day} ${Util.getMonthName(tomorrow.month)} ${tomorrow.year}';

              // Display tasks in sections for Today, Tomorrow, and Later
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TaskSectionWidget(
                        title: 'Today', // Today's tasks
                        date: todayFormatted,
                        tasks: data['today'] ?? [],
                      ),
                      TaskSectionWidget(
                        title: 'Tomorrow', // Tomorrow's tasks
                        date: tomorrowFormatted,
                        tasks: data['tomorrow'] ?? [],
                      ),
                      TaskSectionWidget(
                        title: 'Later', // Tasks for later days
                        date: 'Upcoming Days', // Generic label for "Later"
                        tasks: data['later'] ?? [], // Use "later" key for tasks beyond tomorrow
                      ),
                    ],
                  ),
                ),
              );
            }
            // Default message if no data is available
            else {
              return const Center(child: Text('No tasks available.'));
            }
          },
        ),
      ),
    );
  }
}
