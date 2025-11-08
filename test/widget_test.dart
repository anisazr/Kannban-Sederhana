import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:todo_list/main.dart';

void main() {
  testWidgets('Kanban board loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Verify that the Kanban board widget loads
    expect(find.byType(KanbanBoard), findsOneWidget);

    // Verify that the app bar title exists
    expect(find.text('To Do Board'), findsOneWidget);

    // Verify that the three columns exist
    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('Doing'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Verify that the floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Can open add task dialog', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Find and tap the add button
    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Verify that the dialog appears
    expect(find.text('Tambah To Do'), findsOneWidget);
    expect(find.text('Masukkan nama kegiatan'), findsOneWidget);
  });

  testWidgets('Can add a new task', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter text in the dialog
    await tester.enterText(find.byType(TextField), 'Test Task');
    await tester.pumpAndSettle();

    // Tap the Tambah button
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Verify that the task was added
    expect(find.text('Test Task'), findsOneWidget);
  });

  testWidgets('Task card shows user name', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Add a task
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Task with User');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Verify that the task shows "Oleh: " (Created by)
    expect(find.textContaining('Oleh:'), findsOneWidget);
  });

  testWidgets('Can move task to next column', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Add a task first
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Movable Task');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Find the arrow forward button and tap it
    final moveButton = find.byIcon(Icons.arrow_forward).first;
    await tester.tap(moveButton);
    await tester.pumpAndSettle();

    // Task should still exist (just moved)
    expect(find.text('Movable Task'), findsOneWidget);
  });

  testWidgets('Can delete a task', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Add a task first
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Task to Delete');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Verify task exists
    expect(find.text('Task to Delete'), findsOneWidget);

    // Find and tap the delete button
    final deleteButton = find.byIcon(Icons.delete).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify task is deleted
    expect(find.text('Task to Delete'), findsNothing);
  });

  testWidgets('User info and logout buttons exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Verify that user info button exists
    expect(find.byIcon(Icons.person), findsOneWidget);

    // Verify that logout button exists
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('Task is draggable', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Add a task first
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Draggable Task');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Find the draggable widget
    final draggableTask = find.byType(Draggable<Task>).first;

    // Verify draggable exists
    expect(draggableTask, findsOneWidget);
  });

  testWidgets('DragTarget accepts tasks', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: KanbanBoard()));

    // Verify that DragTarget widgets exist for each column
    expect(find.byType(DragTarget<Task>), findsNWidgets(3)); // 3 columns
  });
}
