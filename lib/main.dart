import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'To Do Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: isLoggedIn ? '/kanban' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/kanban', page: () => KanbanBoard()),
      ],
    );
  }
}

// Model Task
class Task {
  String id;
  String title;
  String status;
  String createdBy;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.createdBy,
  });
}

// Controller menggunakan GetX
class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var currentUser = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  // Load nama User dari SharedPreferences
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser.value = prefs.getString('nama_lengkap') ?? 'User';
  }

  void addTask(String title) {
    tasks.add(
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        status: 'todo',
        createdBy: currentUser.value,
      ),
    );
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

  void updateTaskStatus(String id, String newStatus) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].status = newStatus;
      tasks.refresh();
    }
  }
}

// Tampilan utama Kanban Board
class KanbanBoard extends StatelessWidget {
  final TaskController c = Get.put(TaskController());

  KanbanBoard({super.key});

  Future<void> _logout() async {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah Anda yakin ingin logout?',
      textCancel: 'Batal',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', false);
        Get.offAllNamed('/login');
      },
    );
  }

  Future<void> _showUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final namaLengkap = prefs.getString('nama_lengkap') ?? 'User';
    final email = prefs.getString('email') ?? 'user@email.com';

    Get.defaultDialog(
      title: 'Informasi User',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            namaLengkap,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text('Tutup', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Do Board',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showUserInfo,
            tooltip: 'Informasi User',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(() {
        final todo = c.tasks.where((t) => t.status == 'todo').toList();
        final doing = c.tasks.where((t) => t.status == 'doing').toList();
        final done = c.tasks.where((t) => t.status == 'done').toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColumn('To Do', todo, Colors.amber, 'todo'),
            buildColumn('Doing', doing, Colors.greenAccent, 'doing'),
            buildColumn('Done', done, Colors.lightBlueAccent, 'done'),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => showAddDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Expanded buildColumn(
    String title,
    List<Task> items,
    Color color,
    String status,
  ) {
    return Expanded(
      child: DragTarget<Task>(
        onAccept: (task) {
          c.updateTaskStatus(task.id, status);
          Get.snackbar(
            'Berhasil',
            'Task dipindah ke $title',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
          );
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
              color:
                  candidateData.isNotEmpty
                      ? color.withValues(alpha: 0.1)
                      : Colors.transparent,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: color.withValues(alpha: 0.4),
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
                    children:
                        items.map((task) {
                          return Draggable<Task>(
                            data: task,
                            feedback: Material(
                              elevation: 4,
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Oleh: ${task.createdBy}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: buildTaskCard(task),
                            ),
                            child: buildTaskCard(task),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Oleh: ${task.createdBy}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.status != 'done')
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 20),
                onPressed: () => c.moveTask(task.id),
                tooltip: 'Pindah ke tahap berikutnya',
              ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => showEditDialog(Get.context!, task),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => c.deleteTask(task.id),
              tooltip: 'Hapus',
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
          decoration: const InputDecoration(
            hintText: 'Masukkan nama kegiatan',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                c.addTask(controller.text);
                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Task berhasil ditambahkan',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
              }
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
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                c.editTask(task.id, controller.text);
                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Task berhasil diupdate',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
