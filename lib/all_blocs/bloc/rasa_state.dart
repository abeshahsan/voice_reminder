part of 'rasa_bloc.dart';

@immutable
sealed class RasaState {}

final class RasaInitial extends RasaState {}

final class RasaLoading extends RasaState {}

final class RasaReceivedResponse extends RasaState {
  final String response;

  RasaReceivedResponse(this.response);

  @override
  String toString() => 'RasaReceivedMessage(message: $response)';
}

final class RasaError extends RasaState {
  final String error;

  RasaError(this.error);

  @override
  String toString() => 'RasaError(error: $error)';
}
