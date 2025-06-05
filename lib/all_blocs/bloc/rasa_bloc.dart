import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'rasa_event.dart';
part 'rasa_state.dart';

class RasaBloc extends Bloc<RasaEvent, RasaState> {
  RasaBloc() : super(RasaInitial()) {
    on<RasaEvent>((event, emit) async {
      if (event is RasaSendMessageEvent) {
        await _handleSendMessage(event, emit);
      }
    });
  }

  Future<void> _handleSendMessage(
    RasaSendMessageEvent event,
    Emitter<RasaState> emit,
  ) async {
    emit(RasaLoading());
    try {
      // Here you would typically call your API and get the response
      String response = await fetchAndPrintResponse(event.message);

      emit(RasaReceivedResponse(response));
    } catch (error) {
      emit(RasaError(error.toString()));
    }
  }
}

Future<String> fetchAndPrintResponse(String text) async {
  // http.Response response = await http.post(
  //   Uri.parse(
  //     'http://192.168.0.108:5005/model/parse',
  //   ), // Replace with your API endpoint
  //   headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  //   body: jsonEncode({
  //     'text': text,
  //     'locale': 'en_US',
  //     'tz': 'Asia/Dhaka', // Optional: set your local time zone
  //   }),
  // );
  // if (response.statusCode == 200) {
  //   return response.body;
  // } else {
  //   throw Exception('Failed to fetch response: ${response.statusCode}');
  // }
  return await Future.delayed(
    const Duration(milliseconds: 1000),
    () => 'Dummy Response for "$text"',
  );
}

/**
 * Commit message: 
Incorporated BLOC pattern for state management, separating business logic from UI.
 - Added RasaBloc to manage Rasa events and states
 - Created RasaEvent for sending messages
 - Created RasaState for different states like loading, received response, and error
 - Implemented fetchAndPrintResponse function to simulate API call
 - Updated main.dart to include RasaBloc in MultiBlocProvider
 - Updated SpeechScreen to use RasaBloc for handling speech input and displaying responses
 - Added error handling in RasaBloc
 */
