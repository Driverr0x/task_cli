import 'package:task_cli/exceptions/task_exceptions.dart';
import 'package:task_cli/models/priority.dart';
import 'package:task_cli/services/task_service.dart';
import 'package:test/test.dart';

import 'in_memory_task_repository.dart';

void main() {
  late InMemoryTaskRepository repository;
  late TaskService service;

  setUp(() {
    repository = InMemoryTaskRepository();
    service = TaskService(repository);
  });

  test('addTask() rejette un titre vide via InvalidTaskDataException', () {
    expect(
      () => service.addTask(title: '   ', priority: Priority.low),
      throwsA(isA<InvalidTaskDataException>()),
    );
  });

  test('addTask() crée une UrgentTask de priorité high quand urgent=true', () {
    final task = service.addTask(title: 'Serveur en panne', priority: Priority.low, urgent: true);
    expect(task.priority, Priority.high);
    expect(task.type, 'urgent');
  });

  test('addTask() attribue le prochain id libre du dépôt', () {
    repository.add(SimpleTask(id: '1', title: 'Existante', priority: Priority.low));

    final first = service.addTask(title: 'Première', priority: Priority.low);
    final second = service.addTask(title: 'Deuxième', priority: Priority.low);

    expect(first.id, '2');
    expect(second.id, '3');
  });

  test('listTasks() trie par priorité décroissante par défaut', () {
    service.addTask(title: 'Basse', priority: Priority.low);
    service.addTask(title: 'Haute', priority: Priority.high);
    service.addTask(title: 'Moyenne', priority: Priority.medium);

    final tasks = service.listTasks();

    expect(tasks.map((t) => t.title).toList(), ['Haute', 'Moyenne', 'Basse']);
  });

  test('completeTask() marque la tâche comme terminée', () {
    final task = service.addTask(title: 'À finir', priority: Priority.medium);
    expect(task.completed, isFalse);

    final completed = service.completeTask(task.id);

    expect(completed.completed, isTrue);
    expect(service.getTaskOrThrow(task.id).completed, isTrue);
  });

  test('completeTask() lève TaskNotFoundException pour un id inconnu', () {
    expect(
      () => service.completeTask('id-inexistant'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('deleteTask() retire bien la tâche du dépôt', () {
    final task = service.addTask(title: 'À supprimer', priority: Priority.low);
    expect(service.listTasks(), hasLength(1));

    service.deleteTask(task.id);

    expect(service.listTasks(), isEmpty);
  });
}
