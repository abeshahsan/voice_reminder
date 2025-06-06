part of 'nlu_bloc.dart';

@immutable
sealed class NLUEvent {}

class NLUSendMessageEvent extends NLUEvent {
  final String message;

  NLUSendMessageEvent(this.message);

  @override
  String toString() => 'NLUSendMessageEvent(message: $message)';
}
