import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'stt_event.dart';
part 'stt_state.dart';

class SpeechBloc extends Bloc<SpeechEvent, SpeechState> {
  SpeechBloc() : super(SpeechInitial()) {
    on<SpeechEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
