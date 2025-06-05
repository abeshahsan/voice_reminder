part of 'rasa_bloc.dart';

@immutable
sealed class RasaEvent {}

class RasaSendMessageEvent extends RasaEvent {
  final String message;

  RasaSendMessageEvent(this.message);

  @override
  String toString() => 'RasaSendMessageEvent(message: $message)';
}
