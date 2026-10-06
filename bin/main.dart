import 'dart:io';

import 'package:task_cli/exceptions/task_exceptions.dart';
import 'package:task_cli/models/priority.dart';
import 'package:task_cli/models/task.dart';
import 'package:task_cli/repository/task_repository.dart';
import 'package:task_cli/services/task_service.dart';

const String _defaultDataFile = 'tasks.json';

void main(List<String> arguments) {
  final dataFilePath = Platform.environment['TASK_CLI_FILE'] ?? _defaultDataFile;
  final repository = TaskRepository(dataFilePath);
  final service = TaskService(repository);

  if (arguments.isEmpty) {
    _printUsage();
    exit(0);
  }

  final command = arguments.first;
  final rest = arguments.skip(1).toList();

  try {
    switch (command) {
      case 'add':
        _handleAdd(service, rest);
        break;
      case 'list':
        _handleList(service, rest);
        break;
      case 'done':
        _handleDone(service, rest);
        break;
      case 'delete':
        _handleDelete(service, rest);
        break;
      case 'help':
      case '--help':
      case '-h':
        _printUsage();
        break;
      default:
        stderr.writeln('Commande inconnue : "$command"');
        _printUsage();
        exit(64);
    }
  } on TaskException catch (e) {
    stderr.writeln('Erreur : $e');
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln('Erreur : $e');
    exit(64);
  }
}

void _handleAdd(TaskService service, List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage : add "<titre>" --priority=low|medium|high  --due=jj-mm-aaaa  --urgent ');
    exit(64);
  }

  final title = args.first;
  final options = _parseOptions(args.skip(1).toList());

  final urgent = options.containsKey('urgent');
  final priorityStr = options['priority'] ?? 'medium';
  final priority = Priority.fromString(priorityStr);

  DateTime? dueDate;
  if (options.containsKey('due')) dueDate = _parseDate(options['due']!);

  final task = service.addTask(
    title: title,
    priority: priority,
    dueDate: dueDate,
    urgent: urgent,
  );

  print('Tâche ajoutée : ${task.id}');
  print(task);
}

void _handleList(TaskService service, List<String> args) {
  final options = _parseOptions(args);
  final sortOption = options['sort'] ?? 'priority';
  final sortBy = sortOption == 'due' ? SortBy.dueDate : SortBy.priority;

  final tasks = service.listTasks(sortBy: sortBy);

  if (tasks.isEmpty) {
    print('Aucune tâche enregistrée.');
    return;
  }

  for (final Task task in tasks) {
    print('${task.id}  $task');
  }
}

void _handleDone(TaskService service, List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage : done <id>');
    exit(64);
  }
  final task = service.completeTask(args.first);
  print('Tâche marquée comme terminée : $task');
}

void _handleDelete(TaskService service, List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage : delete <id>');
    exit(64);
  }
  service.deleteTask(args.first);
  print('Tâche supprimée : ${args.first}');
}

Map<String, String> _parseOptions(List<String> args) {
  final options = <String, String>{};
  for (final arg in args) {
    if (!arg.startsWith('--')) continue;
    final stripped = arg.substring(2);
    final eqIndex = stripped.indexOf('=');
    if (eqIndex == -1) {
      options[stripped] = '';
    } else {
      options[stripped.substring(0, eqIndex)] = stripped.substring(eqIndex + 1);
    }
  }
  return options;
}

DateTime _parseDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) throw FormatException('Format de date attendu : jj-mm-aaaa.');

  final isIsoFormat = parts[0].length == 4;
  final day = int.tryParse(isIsoFormat ? parts[2] : parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(isIsoFormat ? parts[0] : parts[2]);
  if (day == null || month == null || year == null) {
    throw FormatException('Format de date attendu : jj-mm-aaaa.');
  }

  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw FormatException('Date invalide : "$value".');
  }
  return date;
}

void _printUsage() {
  print('''
Task CLI — gestionnaire de tâches en ligne de commande

Usage :
  dart run bin/main.dart add "<titre>" [--priority=low|medium|high] [--due=jj-mm-aaaa] [--urgent]
  dart run bin/main.dart list [--sort=priority|due]
  dart run bin/main.dart done <id>
  dart run bin/main.dart delete <id>
  dart run bin/main.dart help

Variables d'environnement :
  TASK_CLI_FILE   Chemin du fichier JSON de persistance (défaut : tasks.json)
''');
}
