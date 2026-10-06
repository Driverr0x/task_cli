import '../interfaces/json_serializable.dart';
import 'priority.dart';

abstract class Task implements JsonSerializable, Comparable<Task> {
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool completed;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Le titre ne peut pas être vide.');
    }
  }

  String get type;

  bool get isOverdue {
    if (dueDate == null || completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  void markCompleted() {
    completed = true;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get sortWeight => priority.weight * 10;

  @override
  int compareTo(Task other) {
    final weightDiff = other.sortWeight.compareTo(sortWeight);
    if (weightDiff != 0) return weightDiff;
    return createdAt.compareTo(other.createdAt);
  }

  @override
  String toString() {
    final status = completed ? '[x]' : '[ ]';
    final due = dueDate != null ? ' (échéance: ${formatDate(dueDate!)})' : '';
    return '$status ($type) $title - priorité: ${priority.name}$due';
  }
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day-$month-${date.year.toString().padLeft(4, '0')}';
}
