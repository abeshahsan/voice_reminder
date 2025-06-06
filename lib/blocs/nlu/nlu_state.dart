part of 'nlu_bloc.dart';

@immutable
sealed class NLUState {}

final class NLUInitial extends NLUState {}

final class NLULoading extends NLUState {}

final class NLUReceivedResponse extends NLUState {
  final String response;

  NLUReceivedResponse(this.response);

  @override
  String toString() => 'NLUReceivedMessage(message: $response)';
}

final class NLUError extends NLUState {
  final String error;

  NLUError(this.error);

  @override
  String toString() => 'NLUError(error: $error)';
}
