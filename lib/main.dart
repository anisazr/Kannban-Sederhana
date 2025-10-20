import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: KanbanBoard()));
}

class Task {
  String id;
  String title;
  String status; // todo, doing, done

  Task({required this.id, required this.title, required this.status});
}

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  List<Task> tasks = [];

  void addTask(String title) {
    setState(() {
      tasks.add(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        status: 'todo',
      ));
    });
  }

  void editTask(String id, String newTitle) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) tasks[index].title = newTitle;
    });
  }

  void deleteTask(String id) {
    setState(() {
      tasks.removeWhere((t) => t.id == id);
    });
  }

  void moveTask(String id) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        if (tasks[index].status == 'todo') {
          tasks[index].status = 'doing';
        } else if (tasks[index].status == 'doing') {
          tasks[index].status = 'done';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todo = tasks.where((t) => t.status == 'todo').toList();
    final doing = tasks.where((t) => t.status == 'doing').toList();
    final done = tasks.where((t) => t.status == 'done').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do Board'),
        backgroundColor: Colors.brown,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildColumn('To Do', todo, Colors.amber),
          buildColumn('Doing', doing, Colors.greenAccent),
          buildColumn('Done', done, Colors.lightBlueAccent),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Expanded buildColumn(String title, List<Task> items, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: color.withOpacity(0.4),
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: items.map((task) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(task.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.status != 'done')
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () => moveTask(task.id),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showEditDialog(context, task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteTask(task.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah To Do'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan nama kegiatan'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) addTask(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(BuildContext context, Task task) {
    final controller = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit To Do'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) editTask(task.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
