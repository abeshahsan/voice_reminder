import 'package:bloc/bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:voice_reminder/models/task_model.dart';

part 'task_event.dart';
part 'task_state.dart';

// some dummy data for testing
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

  List<Task> get allTasks => _tasks;

  TaskBloc() : super(TaskInitial()) {
    on<TaskEvent>((event, emit) {
      if (event is TaskLoadEvent) {
        _loadTasks(emit);
      } else if (event is TaskAddEvent) {
        _addTask(event.task, emit);
        } else if (event is TaskUpdateEvent) {
          _updateTask(event.task, emit);
        // } else if (event is TaskDeleteEvent) {
        //   _deleteTask(event.taskId, emit);
      }
    });
    add(TaskLoadEvent());
  }

  void _loadTasks(Emitter<TaskState> emit) {
    debugPrint('Loading tasks...');
    _tasks = List.from(dummyTasks); // Simulating loading from a database or API
    emit(TaskLoaded(_tasks));
    debugPrint('Tasks loaded: ${_tasks.length}');
  }

  void _addTask(Task task, Emitter<TaskState> emit) {
    debugPrint('Adding task: ${task.title}');
    _tasks.add(task);
    emit(TaskLoaded(_tasks));
    debugPrint('Task added. Total tasks: ${_tasks.length}');
  }

  void _updateTask(Task task, Emitter<TaskState> emit) {
    debugPrint('Updating task: ${task.title}');
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      emit(TaskLoaded(_tasks));
      debugPrint('Task updated. Total tasks: ${_tasks.length}');
    } else {
      debugPrint('Task not found for update: ${task.id}');
    }
  }
}
