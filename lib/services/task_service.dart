import 'package:voice_reminder/database/database_helper.dart';
import 'package:voice_reminder/models/task_model.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Initialize database (useful for app startup)
  Future<void> initializeDatabase() async {
    await _databaseHelper.database;
  }

  // Get all tasks sorted by due date
  Future<List<Task>> getAllTasksSorted() async {
    final tasks = await _databaseHelper.getAllTasks();
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  // Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    final allTasks = await _databaseHelper.getAllTasks();
    final today = DateTime.now();

    return allTasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).toList();
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    final allTasks = await _databaseHelper.getAllTasks();
    final now = DateTime.now();

    return allTasks.where((task) {
      return task.dueDate.isBefore(now);
    }).toList();
  }

  // Get upcoming tasks (next 7 days)
  Future<List<Task>> getUpcomingTasks() async {
    final allTasks = await _databaseHelper.getAllTasks();
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return allTasks.where((task) {
      return task.dueDate.isAfter(now) && task.dueDate.isBefore(nextWeek);
    }).toList();
  }

  // Search tasks by title or description
  Future<List<Task>> searchTasks(String query) async {
    final allTasks = await _databaseHelper.getAllTasks();
    final lowercaseQuery = query.toLowerCase();

    return allTasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
          task.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Backup tasks to JSON (can be useful for export)
  Future<List<Map<String, dynamic>>> exportTasksToJson() async {
    final tasks = await _databaseHelper.getAllTasks();
    return tasks.map((task) => task.toMap()).toList();
  }

  // Import tasks from JSON (can be useful for import)
  Future<void> importTasksFromJson(List<Map<String, dynamic>> tasksJson) async {
    for (final taskMap in tasksJson) {
      final task = Task.fromMap(taskMap);
      await _databaseHelper.insertTask(task);
    }
  }

  // Clear all tasks (useful for testing)
  Future<void> clearAllTasks() async {
    await _databaseHelper.deleteAllTasks();
  }

  // Get task count
  Future<int> getTaskCount() async {
    final tasks = await _databaseHelper.getAllTasks();
    return tasks.length;
  }
}
