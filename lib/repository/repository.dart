/// Contrat générique pour un dépôt de données de type [T].
///
/// Toute implémentation (mémoire, fichier JSON, base de données...) doit
/// fournir ces opérations CRUD de base. L'utilisation de génériques permet
/// de réutiliser ce contrat pour n'importe quel type d'entité identifiable.
abstract interface class Repository<T> {
  /// Retourne toutes les entités.
  List<T> getAll();

  /// Retourne l'entité correspondant à [id], ou `null` si absente.
  T? findById(String id);

  /// Ajoute une nouvelle entité.
  void add(T item);

  /// Met à jour une entité existante.
  void update(T item);

  /// Supprime l'entité correspondant à [id].
  void delete(String id);
}
