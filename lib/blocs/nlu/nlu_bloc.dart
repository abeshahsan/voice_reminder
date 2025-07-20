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
      emit(NLUError(error.toString()));
    }
  }
}

Future<String> fetchAndPrintResponse(String text) async {
  try {
    debugPrint('URL: http://192.168.31.222:5005/model/parse');
    
    http.Response response = await http
        .post(
          Uri.parse('http://192.168.31.222:5005/model/parse'),
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
        .timeout(const Duration(seconds: 10)); // Increased timeout to 10 seconds
    
    debugPrint('Response status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      debugPrint('Response: ${response.body}');
      return response.body;
    } else {
      debugPrint('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch response: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Exception in fetchAndPrintResponse: $e');
    throw Exception('Error fetching response: $e');
  }
}
