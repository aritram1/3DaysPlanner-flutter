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
  DateTime? customDate;
  String taskName = '';
  String priority = 'Medium';
  String category = 'Work';
  bool reminderRequired = false;

  Future<void> createTask() async {

    String tentativeCompletionTime = '';
    if (selectedDateOption == 'Today') {
      tentativeCompletionTime = DateTime.now().toIso8601String();
    } 
    else if (selectedDateOption == 'Tomorrow') {
      tentativeCompletionTime = DateTime.now().add(const Duration(days: 1)).toIso8601String();
    } 
    else {
      tentativeCompletionTime = customDate?.toIso8601String() ?? '';
    }
    
    Map<String, dynamic> taskMap = {
      'Name': taskName,
      'Tentative_Completion_Time__c': tentativeCompletionTime,
      'Priority__c': priority,
      'Category__c': category,
      'Reminder_Required__c': reminderRequired,
      'Status__c': 'Not Started',
    };

    print('taskMap=>${jsonEncode(taskMap)}');
    

    // Call the async method in util.dart
    Map<String, dynamic> result = await SFUtil.saveTaskToSalesforce(taskMap);

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
                      });
                    },
                  ),
                  const Text('Custom'),
                ],
              ),
              if (selectedDateOption == 'Custom')
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Date (MM/DD)',
                    helperText: 'E.g., 05/10',
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
                    } catch (_) {
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