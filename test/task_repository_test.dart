import 'dart:io';

import 'package:task_cli/exceptions/task_exceptions.dart';
import 'package:task_cli/models/priority.dart';
import 'package:task_cli/models/simple_task.dart';
import 'package:task_cli/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String filePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_cli_test_');
    filePath = '${tempDir.path}/tasks.json';
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('add() persiste la tâche dans le fichier JSON', () {
    final repo = TaskRepository(filePath);
    final task = SimpleTask(id: '1', title: 'Écrire le README', priority: Priority.high);

    repo.add(task);

    expect(File(filePath).existsSync(), isTrue);

    final reloaded = TaskRepository(filePath);
    final all = reloaded.getAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Écrire le README');
  });

  test('add() lève DuplicateTaskException pour un id déjà existant', () {
    final repo = TaskRepository(filePath);
    repo.add(SimpleTask(id: '1', title: 'A', priority: Priority.low));

    expect(
      () => repo.add(SimpleTask(id: '1', title: 'B', priority: Priority.low)),
      throwsA(isA<DuplicateTaskException>()),
    );
  });

  test('delete() lève TaskNotFoundException si l\'id est inconnu', () {
    final repo = TaskRepository(filePath);
    expect(() => repo.delete('inexistant'), throwsA(isA<TaskNotFoundException>()));
  });
}
