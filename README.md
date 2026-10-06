# Task CLI

Application en ligne de commande de gestion de tâches, écrite en **Dart pur**
(aucune dépendance Flutter, aucune dépendance externe pour le cœur de
l'application).

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low` / `medium` / `high`, date limite optionnelle)
- Lister toutes les tâches, triées par priorité ou par date limite
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance automatique dans un fichier JSON local (`tasks.json`)

## Choix techniques

| Exigence | Où c'est implémenté |
|---|---|
| Classe abstraite + héritage | `lib/models/task.dart` (`Task`, abstraite) → `lib/models/urgent_task.dart` (`UrgentTask extends Task`) et `lib/models/simple_task.dart` (`SimpleTask extends Task`) |
| Interface | `lib/interfaces/json_serializable.dart` (`JsonSerializable`), implémentée par `Task`. `Task` implémente aussi `Comparable<Task>` (interface du SDK) pour le tri. |
| Génériques | `lib/repository/repository.dart` : `abstract interface class Repository<T>`, implémenté par `TaskRepository implements Repository<Task>` (persistance fichier) et par `InMemoryTaskRepository` dans les tests. |
| Exceptions personnalisées | `lib/exceptions/task_exceptions.dart` : `TaskNotFoundException`, `DuplicateTaskException`, `InvalidTaskDataException`, `PersistenceException`, toutes héritant de `TaskException`. |
| Tests unitaires (≥ 5) | `test/task_model_test.dart`, `test/task_repository_test.dart`, `test/task_service_test.dart` — 13 tests au total avec le package `test`. |

### Architecture

```
bin/main.dart              -> point d'entrée CLI (parsing des arguments, affichage)
lib/models/                -> Task (abstraite), SimpleTask, UrgentTask, Priority
lib/interfaces/            -> JsonSerializable
lib/repository/            -> Repository<T> (interface générique) + TaskRepository (JSON)
lib/services/              -> TaskService (logique métier, indépendante du stockage)
lib/exceptions/            -> Exceptions personnalisées
test/                      -> Tests unitaires + InMemoryTaskRepository (double de test)
```

Le `TaskService` ne dépend que de l'abstraction `Repository<Task>`, jamais de
`TaskRepository` directement : c'est ce qui permet de le tester avec
`InMemoryTaskRepository` sans toucher au système de fichiers.

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0

Vérifier l'installation :

```bash
dart --version
```

## Installation

```bash
git clone <url-du-repo>
cd task_cli
dart pub get
```

## Lancer l'application

```bash
# Ajouter une tâche simple
dart run bin/main.dart add "Faire les courses" --priority=medium --due=20-08-2026

# Ajouter une tâche urgente ( priorité high)
dart run bin/main.dart add "Serveur en panne" --urgent

# Lister les tâches (triées par priorité par défaut)
dart run bin/main.dart list

# Lister les tâches triées par date limite
dart run bin/main.dart list --sort=due

# Marquer une tâche comme terminée (utiliser l'id affiché par `list`)
dart run bin/main.dart done <id>

# Supprimer une tâche
dart run bin/main.dart delete <id>

# Aide
dart run bin/main.dart help
```

Par défaut, les tâches sont sauvegardées dans `tasks.json` à la racine du
projet. Le chemin peut être personnalisé via la variable d'environnement
`TASK_CLI_FILE` :

```bash
TASK_CLI_FILE=/tmp/mes_taches.json dart run bin/main.dart list
```

## Lancer les tests

```bash
dart pub get
dart test
```

Pour un rapport détaillé :

```bash
dart test --reporter expanded
```

## Analyse statique

```bash
dart analyze
```

## Exemple de session

```bash
$ dart run bin/main.dart add "Rédiger le rapport" --priority=high --due=15-08-2026
Tâche ajoutée : 1
[ ] (simple) Rédiger le rapport - priorité: high (échéance: 15-08-2026)

$ dart run bin/main.dart add "Panne critique base de données" --urgent
Tâche ajoutée : 2
[ ] (urgent) Panne critique base de données - priorité: high [escalade niveau 1]

$ dart run bin/main.dart list
2  [ ] (urgent) Panne critique base de données - priorité: high [escalade niveau 1]
1  [ ] (simple) Rédiger le rapport - priorité: high (échéance: 15-08-2026)

$ dart run bin/main.dart done 1
Tâche marquée comme terminée : [x] (simple) Rédiger le rapport - priorité: high (échéance: 15-08-2026)

$ dart run bin/main.dart delete 2
Tâche supprimée : 2
```

## Licence

Projet réalisé dans un cadre pédagogique (validation de maîtrise de Dart).
