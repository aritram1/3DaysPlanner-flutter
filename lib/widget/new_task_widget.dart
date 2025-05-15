import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:threedaysplanner/model/sf_task_model.dart';
import 'package:threedaysplanner/util/sf_util.dart';
import '../util/util.dart';

class NewTaskWidget extends StatefulWidget {
  const NewTaskWidget({super.key});

  @override
  State<NewTaskWidget> createState() => _NewTaskWidgetState();
}

class _NewTaskWidgetState extends State<NewTaskWidget> {
  String selectedDateOption = 'Today';
  // TBC 
  // DateTime customDate = DateTime.now().copyWith(hour: 10, minute: 30);
  DateTime? customDate;

  String taskName = '';
  String priority = 'Medium';
  String category = 'Work';
  bool reminderRequired = false;
  
  String? tentativeCompletionTime;

  final TextEditingController customDateController = TextEditingController();

  Future<void> createTask() async {

    // Check requred fields are filled in, else early return the function
    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a task name.')));
      return;
    }
    if (selectedDateOption == 'Custom' && customDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid date.')));
      return;
    }

    // Clip task name if it exceeds 255 characters
    int taskNameLength = taskName.length;
    if (taskName.length > 255) {
      taskName = taskName.substring(0, 255);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name contains $taskNameLength characters, now clipped to 255 characters.')),
      );
    }

    //String tentativeCompletionTime = '';
    const int hour = 10; // Set the hour to 10 AM
    const int minutes = 30; // Set the minute to 30

    if (selectedDateOption == 'Today') {
      tentativeCompletionTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        0,
        0,
      ).add(const Duration(hours: hour, minutes: minutes)).toIso8601String();
    } 
    else if (selectedDateOption == 'Tomorrow') {
      tentativeCompletionTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day + 1,
        0,
        0,
      ).add(const Duration(hours: hour, minutes: minutes)).toIso8601String();
    } 
    else {
      tentativeCompletionTime = DateTime(
        customDate!.year,
        customDate!.month,
        customDate!.day,
        0,
        0,
      ).add(const Duration(hours: hour, minutes: minutes)).toIso8601String();
    }
    
    Map<String, dynamic> taskMap = {
      'Name': taskName,
      'Tentative_Completion_Time__c': Util.convertISTToGMT(tentativeCompletionTime!), // Convert IST to GMT
      'Priority__c': priority,
      'Category__c': category,
      'Reminder_Required__c': reminderRequired,
      'Status__c': 'Not Started',
    };

    print('taskMap=>${jsonEncode(taskMap)}');
    

    // Call the async method in util.dart
    Map<String, dynamic> result = await SFUtil.createTask(taskMap);

    // Print the result to the console
    print('result inside saveTask=>${(result)}');

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task saved successfully!')),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save task.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio(
                    value: 'Today',
                    groupValue: selectedDateOption,
                    onChanged: (value) {
                      setState(() {
                        selectedDateOption = value!;
                        customDate = null;
                      });
                    },
                  ),
                  const Text('Today'),
                  Radio(
                    value: 'Tomorrow',
                    groupValue: selectedDateOption,
                    onChanged: (value) {
                      setState(() {
                        selectedDateOption = value!;
                        customDate = null;
                      });
                    },
                  ),
                  const Text('Tomorrow'),
                  Radio(
                    value: 'Custom',
                    groupValue: selectedDateOption,
                    onChanged: (value) {
                      setState(() {
                        selectedDateOption = value!;
                        // Set customDate to today + 7 days if not already set
                        if (customDate == null) {
                          final now = DateTime.now();
                          customDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
                          customDateController.text = '${customDate!.month.toString().padLeft(2, '0')}/${customDate!.day.toString().padLeft(2, '0')}';
                        }
                      });
                    },
                  ),
                  const Text('Custom'),
                ],
              ),
              if (selectedDateOption == 'Custom')
                TextField(
                  controller: customDateController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Date (MM/DD)',
                    // helperText: 'e.g., 05/10',
                  ),
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) { 
                    try {
                      final parts = value.split('/');
                      final month = int.parse(parts[0]);
                      final day = int.parse(parts[1]);
                      final year = DateTime.now().year;
                      setState(() {
                        customDate = DateTime(year, month, day);
                      });
                    } 
                    catch (error) {
                      print('error inside catch block of providing custom date => $error');
                      customDate = null;
                    }
                  },
                ),
              if (customDate != null)
                Text(
                  'Day: ${Util.getDayName(customDate!)}',
                  style: TextStyle(
                    color: (customDate!.weekday == 6 || customDate!.weekday == 7) ? Colors.red : Colors.black,
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Task Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Task Name'),
                onChanged: (value) {
                  taskName = value;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio(
                    value: 'High',
                    groupValue: priority,
                    onChanged: (value) {
                      setState(() {
                        priority = value!;
                      });
                    },
                  ),
                  const Text('High'),
                  Radio(
                    value: 'Medium',
                    groupValue: priority,
                    onChanged: (value) {
                      setState(() {
                        priority = value!;
                      });
                    },
                  ),
                  const Text('Medium'),
                  Radio(
                    value: 'Low',
                    groupValue: priority,
                    onChanged: (value) {
                      setState(() {
                        priority = value!;
                      });
                    },
                  ),
                  const Text('Low'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio(
                    value: 'Work',
                    groupValue: category,
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                  ),
                  const Text('Work'),
                  Radio(
                    value: 'Personal',
                    groupValue: category,
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                  ),
                  const Text('Personal'),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Reminder Required'),
                value: reminderRequired,
                onChanged: (value) {
                  setState(() {
                    reminderRequired = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: createTask,
                  child: const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}