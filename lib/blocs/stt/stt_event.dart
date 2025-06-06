part of 'stt_bloc.dart';

@immutable
sealed class STTEvent {}

class STTInitializeEvent extends STTEvent {}

class STTListenEvent extends STTEvent {}
class STTStopListeningEvent extends STTEvent {}

class STTSendNLUMessageEvent extends STTEvent {
  final String message;

  STTSendNLUMessageEvent(this.message);
}

class STTTextChangedEvent extends STTEvent {
  final String text;
  final double confidence;

  STTTextChangedEvent(this.text, this.confidence);
}