import 'package:bloc/bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:voice_reminder/models/task_model.dart';
import 'package:voice_reminder/database/database_helper.dart';

part 'task_event.dart';
part 'task_state.dart';

// some dummy data for testing - will be used for initial population
List<Task> dummyTasks = [
  Task(
    id: '1',
    title: 'Buy groceries',
    description: 'Milk, Bread, Eggs',
    dueDate: DateTime.now().add(Duration(days: 1)),
  ),
  Task(
    id: '2',
    title: 'Walk the dog',
    description: 'Take the dog for a walk in the park',
    dueDate: DateTime.now().add(Duration(days: 2)),
  ),
  Task(
    id: '3',
    title: 'Complete Flutter project',
    description: 'Finish the voice reminder app',
    dueDate: DateTime.now().add(Duration(days: 3)),
  ),
];

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  List<Task> _tasks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Task> get allTasks => _tasks;

  TaskBloc() : super(TaskInitial()) {
    on<TaskEvent>((event, emit) async {
      if (event is TaskLoadEvent) {
        await _loadTasks(emit);
      } else if (event is TaskAddEvent) {
        await _addTask(event.task, emit);
      } else if (event is TaskUpdateEvent) {
        await _updateTask(event.task, emit);
      } else if (event is TaskDeleteEvent) {
        await _deleteTask(event.taskId, emit);
      }
    });
    add(TaskLoadEvent());
  }

  Future<void> _loadTasks(Emitter<TaskState> emit) async {
    try {
      debugPrint('Loading tasks from database...');
      emit(TaskLoading());

      _tasks = await _databaseHelper.getAllTasks();

      // If no tasks in database, populate with dummy data
      if (_tasks.isEmpty) {
        debugPrint('No tasks found in database, populating with dummy data...');
        for (Task task in dummyTasks) {
          await _databaseHelper.insertTask(task);
        }
        _tasks = await _databaseHelper.getAllTasks();
      }

      emit(TaskLoaded(_tasks));
      debugPrint('Tasks loaded: ${_tasks.length}');
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _addTask(Task task, Emitter<TaskState> emit) async {
    try {
      debugPrint('Adding task to database: ${task.title}');
      emit(TaskLoading());

      await _databaseHelper.insertTask(task);
      _tasks = await _databaseHelper.getAllTasks();

      emit(TaskLoaded(_tasks));
      debugPrint('Task added. Total tasks: ${_tasks.length}');
    } catch (e) {
      debugPrint('Error adding task: $e');
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> _updateTask(Task task, Emitter<TaskState> emit) async {
    try {
      debugPrint('Updating task in database: ${task.title}');
      emit(TaskLoading());

      await _databaseHelper.updateTask(task);
      _tasks = await _databaseHelper.getAllTasks();

      emit(TaskLoaded(_tasks));
      debugPrint('Task updated. Total tasks: ${_tasks.length}');
    } catch (e) {
      debugPrint('Error updating task: $e');
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _deleteTask(String id, Emitter<TaskState> emit) async {
    try {
      debugPrint('Deleting task from database with ID: $id');
      emit(TaskLoading());

      await _databaseHelper.deleteTask(id);
      _tasks = await _databaseHelper.getAllTasks();

      emit(TaskLoaded(_tasks));
      debugPrint('Task deleted. Total tasks: ${_tasks.length}');
    } catch (e) {
      debugPrint('Error deleting task: $e');
      emit(TaskError('Failed to delete task: $e'));
    }
  }
}
