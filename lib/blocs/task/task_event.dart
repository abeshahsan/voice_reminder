part of 'task_bloc.dart';

@immutable
sealed class TaskEvent {}

class TaskLoadEvent extends TaskEvent {
  TaskLoadEvent();
}

class TaskAddEvent extends TaskEvent {
  final Task task;

  TaskAddEvent(this.task);
}

class TaskUpdateEvent extends TaskEvent {
  final Task task;

  TaskUpdateEvent(this.task);
}

class TaskDeleteEvent extends TaskEvent {
  final String taskId;

  TaskDeleteEvent(this.taskId);
}
