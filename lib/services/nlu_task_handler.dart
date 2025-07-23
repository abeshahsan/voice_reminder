import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
import 'package:voice_reminder/models/task_model.dart';

class NLUTaskHandler {
  static Future<String> processNLUResponse(
    String nluResponse,
    BuildContext context,
  ) async {
    try {
      final Map<String, dynamic> parsedResponse = jsonDecode(nluResponse);

      // Extract intent and entities
      final String intent = parsedResponse['intent']?['name'] ?? '';
      final List<dynamic> entities = parsedResponse['entities'] ?? [];
      final String text = parsedResponse['text'] ?? '';

      print('Intent: $intent');
      print('Entities: $entities');
      print('Original text: $text');

      switch (intent) {
        case 'create_task':
        case 'add_task':
          return await _handleCreateTask(entities, text, context);

        case 'list_tasks':
        case 'show_tasks':
          return _handleListTasks(context);

        case 'delete_task':
        case 'remove_task':
          return await _handleDeleteTask(entities, text, context);

        case 'update_task':
        case 'edit_task':
          return await _handleUpdateTask(entities, text, context);

        case 'complete_task':
        case 'mark_complete':
          return await _handleCompleteTask(entities, text, context);

        default:
          // If no specific intent is detected, try to extract task information anyway
          return await _handleFallbackTaskCreation(text, context);
      }
    } catch (e) {
      print('Error parsing NLU response: $e');
      // If JSON parsing fails, treat it as raw text and try to process
      return await _handleFallbackTaskCreation(nluResponse, context);
    }
  }

  static Future<String> _handleCreateTask(
    List<dynamic> entities,
    String originalText,
    BuildContext context,
  ) async {
    try {
      String taskTitle = '';
      String taskDescription = '';
      DateTime? dueDate;

      // Extract entities
      for (var entity in entities) {
        switch (entity['entity']) {
          case 'task_name':
          case 'task_title':
            taskTitle = entity['value'] ?? '';
            break;
          case 'task_description':
          case 'description':
            taskDescription = entity['value'] ?? '';
            break;
          case 'due_date':
          case 'date':
            dueDate = _parseDate(entity['value']);
            break;
        }
      }

      // Fallback: if no title found, use the original text
      if (taskTitle.isEmpty) {
        taskTitle = _extractTaskFromText(originalText);
      }

      if (taskTitle.isNotEmpty) {
        // Set default due date if not specified
        dueDate ??= DateTime.now().add(const Duration(days: 1));

        // Create unique ID
        final uniqueId =
            '${DateTime.now().millisecondsSinceEpoch}_${taskTitle.hashCode}';

        final task = Task(
          id: uniqueId,
          title: taskTitle,
          description: taskDescription.isEmpty
              ? 'Added via voice assistant'
              : taskDescription,
          dueDate: dueDate,
        );

        // Add task via TaskBloc
        context.read<TaskBloc>().add(TaskAddEvent(task));

        return 'Task "$taskTitle" has been added successfully! Due date: ${_formatDate(dueDate)}';
      } else {
        return 'I couldn\'t understand the task details. Please try again with a clear task description.';
      }
    } catch (e) {
      return 'Error creating task: ${e.toString()}';
    }
  }

  static String _handleListTasks(BuildContext context) {
    final tasks = context.read<TaskBloc>().allTasks;

    if (tasks.isEmpty) {
      return 'You have no tasks at the moment. Would you like to add one?';
    }

    String response = 'Here are your tasks:\n\n';
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      response += '${i + 1}. ${task.title}\n';
      response += '   Due: ${_formatDate(task.dueDate)}\n';
      if (task.description.isNotEmpty &&
          task.description != 'Added via voice assistant') {
        response += '   Note: ${task.description}\n';
      }
      response += '\n';
    }

    return response.trim();
  }

  static Future<String> _handleDeleteTask(
    List<dynamic> entities,
    String originalText,
    BuildContext context,
  ) async {
    final tasks = context.read<TaskBloc>().allTasks;

    if (tasks.isEmpty) {
      return 'You have no tasks to delete.';
    }

    // Try to find task by title or number
    String taskToDelete = '';
    int? taskNumber;

    for (var entity in entities) {
      if (entity['entity'] == 'task_name' || entity['entity'] == 'task_title') {
        taskToDelete = entity['value'] ?? '';
      } else if (entity['entity'] == 'number') {
        taskNumber = int.tryParse(entity['value'] ?? '');
      }
    }

    // If no specific task found, try to extract from text
    if (taskToDelete.isEmpty && taskNumber == null) {
      final match = RegExp(
        r'delete (?:task )?(?:number )?(\d+)|delete (.+)',
        caseSensitive: false,
      ).firstMatch(originalText);
      if (match != null) {
        if (match.group(1) != null) {
          taskNumber = int.tryParse(match.group(1)!);
        } else if (match.group(2) != null) {
          taskToDelete = match.group(2)!.trim();
        }
      }
    }

    Task? taskToRemove;

    // Find task by number
    if (taskNumber != null && taskNumber > 0 && taskNumber <= tasks.length) {
      taskToRemove = tasks[taskNumber - 1];
    }
    // Find task by title
    else if (taskToDelete.isNotEmpty) {
      taskToRemove = tasks.firstWhere(
        (task) => task.title.toLowerCase().contains(taskToDelete.toLowerCase()),
        orElse: () => tasks.first, // fallback to first task if no match
      );
    }

    if (taskToRemove != null) {
      context.read<TaskBloc>().add(TaskDeleteEvent(taskToRemove.id));
      return 'Task "${taskToRemove.title}" has been deleted successfully!';
    } else {
      return 'I couldn\'t find the task to delete. Please specify the task name or number.';
    }
  }

  static Future<String> _handleUpdateTask(
    List<dynamic> entities,
    String originalText,
    BuildContext context,
  ) async {
    return 'Task update functionality is coming soon. For now, you can manually edit tasks by tapping on them in the list above.';
  }

  static Future<String> _handleCompleteTask(
    List<dynamic> entities,
    String originalText,
    BuildContext context,
  ) async {
    return 'Task completion functionality is coming soon. For now, you can delete completed tasks.';
  }

  static Future<String> _handleFallbackTaskCreation(
    String text,
    BuildContext context,
  ) async {
    // Check for incomplete commands first
    final incompletePatterns = [
      RegExp(r'^(?:add|create|make|new)$', caseSensitive: false),
      RegExp(r'^(?:delete|remove)$', caseSensitive: false),
      RegExp(r'^(?:list|show)$', caseSensitive: false),
      RegExp(r'^(?:remind|remember)$', caseSensitive: false),
    ];

    for (final pattern in incompletePatterns) {
      if (pattern.hasMatch(text.trim())) {
        return 'It looks like you want to ${text.toLowerCase()} something! Try being more specific:\n\n'
            '📝 For adding: "Add task to buy groceries"\n'
            '📋 For listing: "Show my tasks" or "List tasks"\n'
            '🗑️ For deleting: "Delete task 1" or "Remove buy groceries"\n'
            '⏰ For reminders: "Remind me to call John"\n\n'
            'What would you like to do?';
      }
    }

    // Try to detect if this looks like a task creation request
    final taskPatterns = [
      RegExp(
        r'(?:add|create|make|new) (?:a )?(?:task|reminder|todo)(?:\s+(?:to|for))?\s+(.+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:remind me to|remember to|i need to|i have to|i should)\s+(.+)',
        caseSensitive: false,
      ),
      RegExp(r'(.+) (?:by|before|due) (.+)', caseSensitive: false),
    ];

    for (final pattern in taskPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String taskTitle = match.group(1)?.trim() ?? '';
        if (taskTitle.isNotEmpty) {
          // Create the task
          final uniqueId =
              '${DateTime.now().millisecondsSinceEpoch}_${taskTitle.hashCode}';
          final task = Task(
            id: uniqueId,
            title: taskTitle,
            description: 'Added via voice assistant',
            dueDate: DateTime.now().add(const Duration(days: 1)),
          );

          context.read<TaskBloc>().add(TaskAddEvent(task));
          return 'I created a task: "$taskTitle" for you!';
        }
      }
    }

    // If no pattern matches, provide helpful response
    return 'I can help you manage tasks! Try saying:\n'
        '• "Add task to buy groceries"\n'
        '• "Remind me to call John"\n'
        '• "List my tasks"\n'
        '• "Delete task 1"\n\n'
        'What would you like to do?';
  }

  static String _extractTaskFromText(String text) {
    // Remove common command words and extract the task
    final cleanText = text
        .replaceAll(
          RegExp(
            r'(?:add|create|make|new) (?:a )?(?:task|reminder|todo)(?:\s+(?:to|for))?\s+',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'(?:remind me to|remember to|i need to|i have to|i should)\s+',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    return cleanText.isNotEmpty ? cleanText : text;
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    // Simple date parsing - you can enhance this
    final now = DateTime.now();
    final lowerDate = dateStr.toLowerCase();

    if (lowerDate.contains('today')) {
      return now;
    } else if (lowerDate.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    } else if (lowerDate.contains('next week')) {
      return now.add(const Duration(days: 7));
    } else if (lowerDate.contains('monday')) {
      return _getNextWeekday(now, DateTime.monday);
    } else if (lowerDate.contains('tuesday')) {
      return _getNextWeekday(now, DateTime.tuesday);
    } else if (lowerDate.contains('wednesday')) {
      return _getNextWeekday(now, DateTime.wednesday);
    } else if (lowerDate.contains('thursday')) {
      return _getNextWeekday(now, DateTime.thursday);
    } else if (lowerDate.contains('friday')) {
      return _getNextWeekday(now, DateTime.friday);
    } else if (lowerDate.contains('saturday')) {
      return _getNextWeekday(now, DateTime.saturday);
    } else if (lowerDate.contains('sunday')) {
      return _getNextWeekday(now, DateTime.sunday);
    }

    // Try to parse as standard date format
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static DateTime _getNextWeekday(DateTime from, int weekday) {
    final daysUntilWeekday = (weekday - from.weekday + 7) % 7;
    return from.add(
      Duration(days: daysUntilWeekday == 0 ? 7 : daysUntilWeekday),
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
