import 'package:task_cli/exceptions/task_exceptions.dart';
import 'package:task_cli/models/task.dart';
import 'package:task_cli/repository/repository.dart';

/// Implémentation en mémoire de [Repository]<Task>, utilisée uniquement
/// dans les tests pour isoler [TaskService] du système de fichiers.
///
/// Démontre également que le service ne dépend que de l'abstraction
/// générique [Repository], et non d'une implémentation concrète.
class InMemoryTaskRepository implements Repository<Task> {
  final List<Task> _tasks = [];

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  @override
  Task? findById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  void add(Task item) {
    if (_tasks.any((t) => t.id == item.id)) {
      throw DuplicateTaskException(item.id);
    }
    _tasks.add(item);
  }

  @override
  void update(Task item) {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) throw TaskNotFoundException(item.id);
    _tasks[index] = item;
  }

  @override
  void delete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    _tasks.removeAt(index);
  }
}
