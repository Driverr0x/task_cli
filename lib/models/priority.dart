/// Niveau de priorité d'une tâche.
enum Priority {
  low,
  medium,
  high;

  /// Convertit une chaîne de caractères (insensible à la casse) en [Priority].
  ///
  /// Lève une [FormatException] si la valeur ne correspond à aucune priorité.
  static Priority fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return Priority.values.firstWhere(
      (p) => p.name == normalized,
      orElse: () => throw FormatException(
        'Priorité invalide : "$value". Valeurs attendues : low, medium, high.',
      ),
    );
  }

  /// Poids numérique utilisé pour le tri (high = plus prioritaire).
  int get weight {
    switch (this) {
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
    }
  }
}
