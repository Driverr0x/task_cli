import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/simple_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/repository.dart';

enum SortBy { priority, dueDate }

class TaskService {
  final Repository<Task> _repository;
  int _nextId = 1;

  TaskService(this._repository);

  String _generateId() {
    final usedIds = _repository.getAll().map((task) => task.id).toSet();
    while (usedIds.contains(_nextId.toString())) {
      _nextId++;
    }
    return (_nextId++).toString();
  }

  Task addTask({
    required String title,
    required Priority priority,
    DateTime? dueDate,
    bool urgent = false,
  }) {
    if (title.trim().isEmpty) {
      throw InvalidTaskDataException('Le titre de la tâche ne peut pas être vide.');
    }
    if (dueDate != null && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw InvalidTaskDataException('La date limite ne peut pas être dans le passé.');
    }

    final id = _generateId();
    final task = urgent
        ? UrgentTask(id: id, title: title, dueDate: dueDate)
        : SimpleTask(id: id, title: title, priority: priority, dueDate: dueDate);

    _repository.add(task);
    return task;
  }

  List<Task> listTasks({SortBy sortBy = SortBy.priority}) {
    final tasks = List<Task>.from(_repository.getAll());
    switch (sortBy) {
      case SortBy.priority:
        tasks.sort();
        break;
      case SortBy.dueDate:
        tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
    }
    return tasks;
  }

  Task completeTask(String id) {
    final task = _repository.findById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    task.markCompleted();
    _repository.update(task);
    return task;
  }

  void deleteTask(String id) {
    _repository.delete(id);
  }

  Task getTaskOrThrow(String id) {
    final task = _repository.findById(id);
    if (task == null) throw TaskNotFoundException(id);
    return task;
  }
}
