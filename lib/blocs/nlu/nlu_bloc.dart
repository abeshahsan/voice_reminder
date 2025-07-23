import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'nlu_event.dart';
part 'nlu_state.dart';

class NLUBloc extends Bloc<NLUEvent, NLUState> {
  NLUBloc() : super(NLUInitial()) {
    on<NLUEvent>((event, emit) async {
      if (event is NLUSendMessageEvent) {
        await _handleSendMessage(event, emit);
      }
    });
  }

  Future<void> _handleSendMessage(
    NLUSendMessageEvent event,
    Emitter<NLUState> emit,
  ) async {
    emit(NLULoading());
    try {
      String response = await fetchAndPrintResponse(event.message);
      emit(NLUReceivedResponse(response));
    } catch (error) {
      print('NLU Error: $error');
      // Fallback: return the original message in a simple JSON format for local processing
      final fallbackResponse = jsonEncode({
        'text': event.message,
        'intent': {'name': 'fallback'},
        'entities': [],
        'intent_ranking': [],
      });
      emit(NLUReceivedResponse(fallbackResponse));
    }
  }
}

Future<String> fetchAndPrintResponse(String text) async {
  try {
    final url = 'http://192.168.31.28:5005/model/parse';

    http.Response response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'text': text,
            'locale': 'en_US',
            'tz': 'Asia/Dhaka',
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Rasa connection error: $e');
    throw Exception('Failed to connect to Rasa server');
  }
}
