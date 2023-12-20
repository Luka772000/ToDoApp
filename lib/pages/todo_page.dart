import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todoapp/db/tasks_db.dart';
import 'package:todoapp/models/task_model.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _textController = TextEditingController();
  late List<Task> tasks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> addTask(String taskName) async {
    if (taskName.isNotEmpty) {
      try {
        await TasksDatabase.instance.create(Task(name: taskName));
        refreshTasks();
      } catch (e) {
        print('Error adding task: $e');
      }
    }
  }

  Future<void> refreshTasks() async {
    setState(() => isLoading = true);

    try {
      this.tasks = await TasksDatabase.instance.readAllTasks();
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> openDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 232, 131),
          title: const Text('Add a TO DO Task'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Task',
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                addTask(_textController.text);
                _textController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('ADD'),
              style: TextButton.styleFrom(
                shape:CircleBorder(),
                backgroundColor: Color.fromARGB(255, 253, 214, 17),
              ),
            ),
          ],
        );
      },
    );
  }

  FloatingActionButton addButton() {
    return FloatingActionButton(
      onPressed: openDialog,
      child: const Icon(Icons.add),
      backgroundColor: Color.fromARGB(255, 253, 214, 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 253, 214, 17),
        title: const Center(child: Text('TO DO')),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ToDoList(
              tasks: tasks,
              onToggle: (Task task, bool value) async {
                try {
                  await TasksDatabase.instance.update(task.copy(isDone: value));
                  refreshTasks();
                } catch (e) {
                  print('Error updating task: $e');
                }
              },
            ),
      backgroundColor: Color.fromARGB(255, 255, 232, 131),
      floatingActionButton: addButton(),
    );
  }
}

class ToDoList extends StatefulWidget {
  final List<Task> tasks;
  final void Function(Task, bool) onToggle;

  const ToDoList({
    Key? key,
    required this.tasks,
    required this.onToggle,
  }) : super(key: key);

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Slidable(  
            endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  _deleteTask(task);
                },
                backgroundColor: Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
            child: CheckboxListTile(
              title: Text(
                task.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              checkColor: Colors.yellow.shade700,
              activeColor: Colors.white,
              value: task.isDone,
              onChanged: (bool? value) {
                if (value != null) {
                  widget.onToggle(task, value);
                }
              },
              tileColor: Colors.yellow.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        );
      },
    );
  }

  void _deleteTask(Task task) async {
    try {
      await TasksDatabase.instance.delete(task.id!);
      widget.onToggle(task, true); // Optionally refresh or use state management to update UI
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}
