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
      // Here you would typically call your API and get the response
      String response = await fetchAndPrintResponse(event.message);

      emit(NLUReceivedResponse(response));
    } catch (error) {
      emit(NLUError(error.toString()));
    }
  }
}

Future<String> fetchAndPrintResponse(String text) async {
  try {
    http.Response response = await http
        .post(
          Uri.parse(
            'http://192.168.0.106:5005/model/parse',
          ), // Replace with your API endpoint
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'text': text,
            'locale': 'en_US',
            'tz': 'Asia/Dhaka', // Optional: set your local time zone
          }),
        )
        .timeout(const Duration(seconds: 3));
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
