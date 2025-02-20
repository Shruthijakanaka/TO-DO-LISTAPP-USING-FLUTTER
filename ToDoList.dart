import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  String description;
  bool isCompleted;
  Task({required this.title, this.description = "", this.isCompleted = false});
}

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  void addTask(String title, String description) {
    tasks.add(Task(title: title, description: description));
    notifyListeners();
  }

  void editTask(int index, String newTitle, String newDescription) {
    tasks[index].title = newTitle;
    tasks[index].description = newDescription;
    notifyListeners();
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    notifyListeners();
  }

  void toggleComplete(int index) {
    tasks[index].isCompleted = !tasks[index].isCompleted;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: TodoScreen(),
      ),
    );
  }
}

class TodoScreen extends StatelessWidget {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To-Do List", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) => Padding(
          padding: EdgeInsets.all(12),
          child: taskProvider.tasks.isEmpty
              ? Center(child: Text("No tasks yet!", style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) => taskProvider.toggleComplete(index),
                          activeColor: Colors.green,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(task.description, style: TextStyle(color: Colors.grey[600])),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                titleController.text = task.title;
                                descController.text = task.description;
                                showTaskDialog(context, taskProvider, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => taskProvider.deleteTask(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          titleController.clear();
          descController.clear();
          showTaskDialog(context, Provider.of<TaskProvider>(context, listen: false), null);
        },
      ),
    );
  }

  void showTaskDialog(BuildContext context, TaskProvider taskProvider, int? index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(index == null ? "New Task" : "Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            SizedBox(height: 10),
            TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (index == null) {
                taskProvider.addTask(titleController.text, descController.text);
              } else {
                taskProvider.editTask(index, titleController.text, descController.text);
              }
              Navigator.pop(context);
            },
            child: Text(index == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }
}
