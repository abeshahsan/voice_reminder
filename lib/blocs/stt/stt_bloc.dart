import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'stt_event.dart';
part 'stt_state.dart';

class STTBloc extends Bloc<STTEvent, STTState> {
  final stt.SpeechToText speech = stt.SpeechToText();
  bool available = false;
  bool isMicOn = false;
  String recognizedText = '';
  String _lastEmittedText = ''; // Track last emitted text to prevent duplicates

  Future<void> initSTT() async {
    available = await speech.initialize(
      onStatus: (status) {
        debugPrint('STT Status: $status');
        if (status == 'done' || status == 'notListening') {
          if (isMicOn) {
            add(STTStopListeningEvent());
          }
        }
      },
      onError: (val) {
        debugPrint('STT Error: ${val.errorMsg}');
        if (isMicOn) {
          add(STTStopListeningEvent());
        }
      },
    );

    isMicOn = false;

    if (available) {
      debugPrint('Speech to Text initialized successfully');
    } else {
      debugPrint('Speech to Text not available');
    }
  }

  STTBloc() : super(STTStateInitial()) {
    on<STTEvent>((event, emit) async {
      if (event is STTInitializeEvent) {
        await initSTT();
      } else if (event is STTListenEvent) {
        if (!available) {
          debugPrint('Speech to Text not available, cannot listen');
          return;
        }

        debugPrint('Starting to listen...');
        isMicOn = true;
        recognizedText = ''; // Clear previous text
        _lastEmittedText = ''; // Reset last emitted text
        emit(STTStateListening());

        speech.listen(
          onResult: (val) {
            debugPrint(
              'STT Result: ${val.recognizedWords} (confidence: ${val.confidence})',
            );
            if (val.recognizedWords.isNotEmpty &&
                val.recognizedWords != _lastEmittedText) {
              recognizedText = val.recognizedWords;
              _lastEmittedText = val.recognizedWords;
              add(STTTextChangedEvent(val.recognizedWords, val.confidence));
            }
          },
          listenFor: const Duration(seconds: 10), // Increased to 10 seconds
          pauseFor: const Duration(seconds: 3), // Increased pause time
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: false, // Changed to false to be more resilient
            listenMode: stt.ListenMode.dictation,
          ),
        );
      } else if (event is STTStopListeningEvent) {
        debugPrint('Stopping listening...');
        isMicOn = false;
        await speech.stop();

        // Auto-send to NLU if we have recognized text
        if (recognizedText.trim().isNotEmpty) {
          debugPrint('Auto-sending to NLU: $recognizedText');
          emit(STTAutoSendToNLU(recognizedText.trim()));
        } else {
          debugPrint('No text recognized, returning to initial state');
          emit(STTStateInitial());
        }
      } else if (event is STTSendNLUMessageEvent) {
        // Reset to initial state after sending
        debugPrint('Resetting STT state after NLU send');
        emit(STTStateInitial());
      } else if (event is STTTextChangedEvent) {
        debugPrint(
          'Text changed: ${event.text} with confidence ${event.confidence}',
        );
        recognizedText = event.text;
        emit(STTtextChanged(event.text, event.confidence));
      }
    });

    add(STTInitializeEvent());
  }
}
