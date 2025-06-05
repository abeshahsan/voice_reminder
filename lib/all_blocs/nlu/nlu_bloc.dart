import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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
