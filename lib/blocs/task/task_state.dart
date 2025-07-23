part of 'task_bloc.dart';

@immutable
sealed class TaskState {}

final class TaskInitial extends TaskState {}

final class TaskLoading extends TaskState {}

final class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);

  @override
  String toString() => 'TaskLoaded { tasks: $tasks }';
}

final class TaskError extends TaskState {
  final String message;

  TaskError(this.message);

  @override
  String toString() => 'TaskError { message: $message }';
}
