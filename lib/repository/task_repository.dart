import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/simple_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import 'repository.dart';

/// Dépôt de tâches persistant les données dans un fichier JSON local.
///
/// Implémente l'interface générique [Repository] spécialisée pour [Task].
class TaskRepository implements Repository<Task> {
  final File _file;
  final List<Task> _tasks = [];
  bool _loaded = false;

  TaskRepository(String path) : _file = File(path);

  /// Charge les tâches depuis le fichier JSON (si présent). Idempotent :
  /// n'a d'effet qu'au premier appel, sauf si [force] est vrai.
  void load({bool force = false}) {
    if (_loaded && !force) return;
    _tasks.clear();

    if (!_file.existsSync()) {
      _loaded = true;
      return;
    }

    try {
      final content = _file.readAsStringSync();
      if (content.trim().isEmpty) {
        _loaded = true;
        return;
      }
      final decoded = jsonDecode(content) as List<dynamic>;
      for (final raw in decoded) {
        _tasks.add(_taskFromJson(raw as Map<String, dynamic>));
      }
      _loaded = true;
    } on FormatException catch (e) {
      throw PersistenceException('Le fichier de données JSON est corrompu.', cause: e);
    } on IOException catch (e) {
      throw PersistenceException('Impossible de lire le fichier "${_file.path}".', cause: e);
    }
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'simple';
    switch (type) {
      case 'urgent':
        return UrgentTask.fromJson(json);
      case 'simple':
      default:
        return SimpleTask.fromJson(json);
    }
  }

  void _persist() {
    try {
      final jsonList = _tasks.map((t) => t.toJson()).toList();
      final encoder = const JsonEncoder.withIndent('  ');
      _file.parent.createSync(recursive: true);
      _file.writeAsStringSync(encoder.convert(jsonList));
    } on IOException catch (e) {
      throw PersistenceException('Impossible d\'écrire dans le fichier "${_file.path}".', cause: e);
    }
  }

  @override
  List<Task> getAll() {
    load();
    return List.unmodifiable(_tasks);
  }

  @override
  Task? findById(String id) {
    load();
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  void add(Task item) {
    load();
    if (_tasks.any((t) => t.id == item.id)) {
      throw DuplicateTaskException(item.id);
    }
    _tasks.add(item);
    _persist();
  }

  @override
  void update(Task item) {
    load();
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException(item.id);
    }
    _tasks[index] = item;
    _persist();
  }

  @override
  void delete(String id) {
    load();
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }
    _tasks.removeAt(index);
    _persist();
  }
}
