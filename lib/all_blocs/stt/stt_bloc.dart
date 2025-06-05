import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'stt_event.dart';
part 'stt_state.dart';

class STTBloc extends Bloc<STTEvent, STTState> {
  final stt.SpeechToText speech = stt.SpeechToText();
  bool available = false;
  bool _isMicOn = false;

  Future<void> initSTT() async {
    available = await speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _isMicOn) {
          Future.delayed(const Duration(milliseconds: 500), () {
            add(STTListenEvent());
          });
        }
      },
      onError: (val) {
        debugPrint('Error: ${val.errorMsg}');
      },
    );

    if (available) {
      debugPrint('Speech to Text initialized successfully');
    } else {
      debugPrint('Speech to Text not available');
    }
  }

  STTBloc() : super(STTStateInitial()) {
    on<STTEvent>((event, emit) async {
      if (event is STTInitializeEvent) {
        _isMicOn = false;
        await initSTT();
      } else if (event is STTListenEvent) {
        _isMicOn = true;
        emit(STTStateListening());
        _keepListening(emit);
      } else if (event is STTStopListeningEvent) {
        _isMicOn = false;
        await speech.stop();
        emit(STTStateInitial());
      } else if (event is STTTextChangedEvent) {
        debugPrint(
          'Text changed: ${event.text} with confidence ${event.confidence}',
        );
        emit(STTtextChanged(event.text, event.confidence));
      }
    });

    add(STTInitializeEvent());
  }
  void _keepListening(Emitter<STTState> emit) {
    if (!available) {
      debugPrint('Speech to Text not available, cannot listen');
      return;
    }
    _isMicOn = true;

    speech.listen(
      onResult: (val) {
        if (val.hasConfidenceRating && val.confidence > 0) {
          add(STTTextChangedEvent(val.recognizedWords, val.confidence));
        }
      },
      listenFor: const Duration(seconds: 30),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }
}
