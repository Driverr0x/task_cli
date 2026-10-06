import 'priority.dart';
import 'task.dart';

/// Tâche urgente : toujours de priorité [Priority.high] et associée à un
/// niveau d'escalade qui augmente le poids de tri.
///
/// Illustre l'héritage (Task -> UrgentTask) : la sous-classe redéfinit
/// [type], [compareTo] et enrichit [toJson].
class UrgentTask extends Task {
  /// Niveau d'escalade (1 = urgent simple, 3 = critique).
  int escalationLevel;

  UrgentTask({
    required String id,
    required String title,
    DateTime? dueDate,
    bool completed = false,
    DateTime? createdAt,
    this.escalationLevel = 1,
  }) : super(
          id: id,
          title: title,
          priority: Priority.high,
          dueDate: dueDate,
          completed: completed,
          createdAt: createdAt,
        ) {
    if (escalationLevel < 1 || escalationLevel > 3) {
      throw ArgumentError.value(
        escalationLevel,
        'escalationLevel',
        "Le niveau d'escalade doit être compris entre 1 et 3.",
      );
    }
  }

  @override
  String get type => 'urgent';

  /// Une tâche urgente passe toujours avant une tâche normale de même
  /// priorité (high), et les tâches urgentes entre elles sont départagées
  /// par leur niveau d'escalade.
  @override
  int get sortWeight => super.sortWeight + escalationLevel;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['escalationLevel'] = escalationLevel;
    return json;
  }

  @override
  String toString() => '${super.toString()} [escalade niveau $escalationLevel]';

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      escalationLevel: json['escalationLevel'] as int? ?? 1,
    );
  }
}
