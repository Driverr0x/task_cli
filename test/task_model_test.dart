import 'package:task_cli/models/priority.dart';
import 'package:task_cli/models/simple_task.dart';
import 'package:task_cli/models/task.dart';
import 'package:task_cli/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('Priority', () {
    test('fromString accepte les valeurs valides, insensibles à la casse', () {
      expect(Priority.fromString('high'), Priority.high);
      expect(Priority.fromString('Medium'), Priority.medium);
      expect(Priority.fromString(' LOW '), Priority.low);
    });

    test('fromString lève une FormatException pour une valeur invalide', () {
      expect(() => Priority.fromString('urgentissime'), throwsFormatException);
    });
  });

  group('SimpleTask', () {
    test('affiche la date limite au format jj-mm-aaaa', () {
      final task = SimpleTask(
        id: '1',
        title: 'Test',
        priority: Priority.low,
        dueDate: DateTime(2026, 8, 19),
      );

      expect(task.toString(), contains('échéance: 19-08-2026'));
    });

    test('un titre vide lève une ArgumentError', () {
      expect(
        () => SimpleTask(id: '1', title: '   ', priority: Priority.low),
        throwsArgumentError,
      );
    });

    test('toJson / fromJson conservent les données (round-trip)', () {
      final task = SimpleTask(
        id: 'abc',
        title: 'Faire les courses',
        priority: Priority.medium,
        dueDate: DateTime(2026, 12, 31),
      );

      final json = task.toJson();
      final rebuilt = SimpleTask.fromJson(json);

      expect(rebuilt.id, task.id);
      expect(rebuilt.title, task.title);
      expect(rebuilt.priority, task.priority);
      expect(rebuilt.dueDate, task.dueDate);
      expect(rebuilt.completed, isFalse);
    });

    test('markCompleted met completed à true', () {
      final task = SimpleTask(id: '1', title: 'Test', priority: Priority.low);
      expect(task.completed, isFalse);
      task.markCompleted();
      expect(task.completed, isTrue);
    });
  });

  group('UrgentTask (héritage de Task)', () {
    test('une UrgentTask est toujours de priorité high', () {
      final task = UrgentTask(id: '1', title: 'Incident critique');
      expect(task.priority, Priority.high);
    });

    test('un niveau d\'escalade hors de [1,3] lève une ArgumentError', () {
      expect(
        () => UrgentTask(id: '1', title: 'Test', escalationLevel: 5),
        throwsArgumentError,
      );
    });

    test('compareTo priorise le niveau d\'escalade le plus élevé', () {
      final low = UrgentTask(id: '1', title: 'A', escalationLevel: 1);
      final high = UrgentTask(id: '2', title: 'B', escalationLevel: 3);
      expect(high.compareTo(low), lessThan(0));
    });

    test('une UrgentTask passe avant une tâche high normale au tri', () {
      final urgent = UrgentTask(id: '1', title: 'Urgent');
      final normalHigh = SimpleTask(id: '2', title: 'Normal high', priority: Priority.high);
      expect(urgent.compareTo(normalHigh), lessThan(0));
    });
  });
}
