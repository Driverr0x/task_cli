/// Exception de base pour toutes les erreurs liées aux tâches.
abstract class TaskException implements Exception {
  final String message;
  TaskException(this.message);

  @override
  String toString() => message;
}

/// Levée lorsqu'aucune tâche ne correspond à l'identifiant demandé.
class TaskNotFoundException extends TaskException {
  final String taskId;
  TaskNotFoundException(this.taskId) : super('Aucune tâche trouvée avec l\'id "$taskId".');
}

/// Levée lorsqu'une tâche avec le même identifiant existe déjà.
class DuplicateTaskException extends TaskException {
  final String taskId;
  DuplicateTaskException(this.taskId) : super('Une tâche avec l\'id "$taskId" existe déjà.');
}

/// Levée lorsque les données d'une tâche sont invalides (titre vide,
/// priorité inconnue, date malformée, etc.).
class InvalidTaskDataException extends TaskException {
  InvalidTaskDataException(super.message);
}

/// Levée lorsqu'une opération de persistance (lecture/écriture du fichier
/// JSON) échoue.
class PersistenceException extends TaskException {
  final Object? cause;
  PersistenceException(String message, {this.cause}) : super(message);

  @override
  String toString() => cause != null ? '$message (cause: $cause)' : message;
}
