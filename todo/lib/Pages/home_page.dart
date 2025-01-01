import 'package:flutter/material.dart';
import 'package:todo/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> pendingTasks = [];
  List<Map<String, dynamic>> completedTasks = [];

  void checkBoxChanged(int index, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        // Move task to completedTasks
        completedTasks.add(pendingTasks[index]);
        pendingTasks.removeAt(index);
      } else {
        // Move task back to pendingTasks
        pendingTasks.add(completedTasks[index]);
        completedTasks.removeAt(index);
      }
    });
  }

  void saveNewTask() async {
    // Ensure the user has entered a task name
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    // Show Date Picker
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) {
      // User canceled date picker
      // Save the task
      setState(() {
        pendingTasks.add({
          'taskName': _controller.text,
        });
        _controller.clear();
      });
    }
    else {
      DateTime now = DateTime.now();
      int hour = now.hour;
      int minute = now.minute;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        hour = time.hour;
        minute = time.minute;
      }
      final selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
      setState(() {
        pendingTasks.add({
          'taskName': _controller.text,
          'dateTime': selectedDateTime, // Include the selected dateTime
        });
        _controller.clear();
      });
    }

    // Save the task

  }

  void deleteTask(int index, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedTasks.removeAt(index);
      } else {
        pendingTasks.removeAt(index);
      }
    });
  }

  Future<void> addOrUpdateDateTime(int index, bool isPending) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isPending) {
            // Update pending task's dateTime
            pendingTasks[index]['dateTime'] = selectedDateTime;
          } else {
            // Update completed task's dateTime
            completedTasks[index]['dateTime'] = selectedDateTime;
          }
        });
      }
    }
  }


  void sorting() {
    setState(() {
      pendingTasks.sort();
    });
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController();
    String currentTask = pendingTasks[index]['taskName'];
    editController.text = currentTask;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: "Task Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pendingTasks[index]['taskName'] = editController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }


  void reorderData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = pendingTasks.removeAt(oldIndex);
      pendingTasks.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Todo-list',
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Pending",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                decoration: TextDecoration.underline,
                decorationColor: Colors.yellow,
                decorationThickness: 2,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: reorderData,
              children: [
                for (int index = 0; index < pendingTasks.length; index++)
                  Container(
                    key: ValueKey(pendingTasks[index]),
                    child: TodoList(
                      taskName: pendingTasks[index]['taskName'],
                      taskCompleted: false,
                      dateTime: pendingTasks[index]['dateTime'],
                      onChanged: (value) => checkBoxChanged(index, true),
                      deleteFunction: (context) => deleteTask(index, false),
                      editFunction: () => editTask(index),
                      onAddDateTime: () => addOrUpdateDateTime(index, true),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Completed",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                decoration: TextDecoration.underline,
                decorationColor: Colors.yellow,
                decorationThickness: 2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (BuildContext context, index) {
                return TodoList(
                  taskName: completedTasks[index]['taskName'],
                  taskCompleted: true,
                  dateTime: completedTasks[index]['dateTime'],
                  onChanged: (value) => checkBoxChanged(index, false),
                  deleteFunction: (context) => deleteTask(index, true),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.yellow.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.yellow,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.yellow,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: saveNewTask,
              backgroundColor: Colors.yellow,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}