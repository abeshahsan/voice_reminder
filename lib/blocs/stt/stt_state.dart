part of 'stt_bloc.dart';

@immutable
sealed class STTState {}

final class STTStateInitial extends STTState {
  final String text;

  STTStateInitial({this.text = "Press the button and start speaking"});
}

class STTStateListening extends STTState {}

final class STTtextChanged extends STTStateListening {
  final String text;
  final double confidence;

  STTtextChanged(this.text, this.confidence);
}

final class STTAutoSendToNLU extends STTState {
  final String message;

  STTAutoSendToNLU(this.message);
}
