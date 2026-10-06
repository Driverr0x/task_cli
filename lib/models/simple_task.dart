import 'priority.dart';
import 'task.dart';

/// Tâche standard, sans comportement particulier.
class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.completed,
    super.createdAt,
  });

  @override
  String get type => 'simple';

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
