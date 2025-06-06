import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/all_blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/all_blocs/stt/stt_bloc.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Reminder'), centerTitle: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BlocBuilder<STTBloc, STTState>(
        builder: (context, state) {
          bool isMicOn = context.read<STTBloc>().isMicOn;
          debugPrint('Mic is ${isMicOn ? "ON" : "OFF"}');
          return FloatingActionButton(
            backgroundColor: isMicOn
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                : Colors.red,
            foregroundColor: Colors.white,
            onPressed: () {
              if (!isMicOn) {
                context.read<STTBloc>().add(STTListenEvent());
              } else {
                context.read<STTBloc>().add(STTStopListeningEvent());
              }
            },
            child: Icon(isMicOn ? Icons.mic : Icons.mic_off),
          );
        },
      ),
      body: BlocBuilder<NLUBloc, NLUState>(
        builder: (context, state) {
          if (state is NLULoading) {
            return const Center(child: CircularProgressIndicator());
          }
          String responseText = "";
          if (state is NLUReceivedResponse) {
            responseText = state.response;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BlocBuilder<STTBloc, STTState>(
                        builder: (context, state) {
                          return TextField(
                            onChanged: (value) =>
                                context.read<STTBloc>().recognizedText = value,

                            controller: TextEditingController(
                              text: context
                                  .read<STTBloc>()
                                  .recognizedText
                                  .trim(),
                            ),
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Type or speak your message...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13.0,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        // Stop listening and send the text to NLU
                        context.read<STTBloc>().add(STTStopListeningEvent());
                        final textToSend = context
                            .read<STTBloc>()
                            .recognizedText
                            .trim();
                        context.read<NLUBloc>().add(
                          NLUSendMessageEvent(textToSend),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    responseText.isNotEmpty
                        ? responseText
                        : 'Response will appear here',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
