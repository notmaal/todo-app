import 'package:flutter/material.dart';
import 'package:todo/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  List pendingTasks = [];
  List completedTasks = [];

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

  void saveNewTask() {
    setState(() {
      pendingTasks.add(_controller.text); // taskName
      _controller.clear();
    });
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

  void sorting() {
    setState(() {
      pendingTasks.sort();
    });
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController();
    String currentTask = pendingTasks[index];
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
                  pendingTasks[index] = editController.text;
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
                      taskName: pendingTasks[index],
                      taskCompleted: false,
                      onChanged: (value) => checkBoxChanged(index, true),
                      deleteFunction: (context) => deleteTask(index, false),
                      editFunction: () => editTask(index), // Edit only for pending
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
                  taskName: completedTasks[index],
                  taskCompleted: true,
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