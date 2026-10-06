/// Interface générique pour tout objet capable de se sérialiser en JSON.
///
/// Toute classe qui implémente cette interface s'engage à fournir
/// une représentation `Map<String, dynamic>` de ses données.
abstract interface class JsonSerializable {
  Map<String, dynamic> toJson();
}
