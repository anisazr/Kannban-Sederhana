import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(GetMaterialApp(home: KanbanBoard()));
}

// Model Task
class Task {
  String id;
  String title;
  String status;

  Task({required this.id, required this.title, required this.status});
}

// Controller menggunakan GetX
class TaskController extends GetxController {
  var tasks = <Task>[].obs;

  void addTask(String title) {
    tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      status: 'todo',
    ));
  }

  void editTask(String id, String newTitle) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].title = newTitle;
      tasks.refresh();
    }
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
  }

  void moveTask(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (tasks[index].status == 'todo') {
        tasks[index].status = 'doing';
      } else if (tasks[index].status == 'doing') {
        tasks[index].status = 'done';
      }
      tasks.refresh();
    }
  }
}

// Tampilan utama
class KanbanBoard extends StatelessWidget {
  final TaskController c = Get.put(TaskController());

  KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Do Board',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final todo = c.tasks.where((t) => t.status == 'todo').toList();
        final doing = c.tasks.where((t) => t.status == 'doing').toList();
        final done = c.tasks.where((t) => t.status == 'done').toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColumn('To Do', todo, Colors.amber),
            buildColumn('Doing', doing, Colors.greenAccent),
            buildColumn('Done', done, Colors.lightBlueAccent),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => showAddDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Expanded buildColumn(String title, List<Task> items, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                              onPressed: () => c.moveTask(task.id),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showEditDialog(Get.context!, task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => c.deleteTask(task.id),
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
    Get.dialog(
      AlertDialog(
        title: const Text('Tambah To Do'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan nama kegiatan'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) c.addTask(controller.text);
              Get.back();
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(BuildContext context, Task task) {
    final controller = TextEditingController(text: task.title);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit To Do'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) c.editTask(task.id, controller.text);
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
