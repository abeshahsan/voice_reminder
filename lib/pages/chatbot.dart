import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/blocs/stt/stt_bloc.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assistant,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Voice Assistant',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type or speak your task below',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: BlocListener<NLUBloc, NLUState>(
              listener: (context, nluState) {
                // Print Rasa response when received
                if (nluState is NLUReceivedResponse) {
                  print('=== RASA RESPONSE ===');
                  print(nluState.response);
                  print('====================');
                } else if (nluState is NLUError) {
                  print('=== RASA ERROR ===');
                  print(nluState.error);
                  print('==================');
                } else if (nluState is NLULoading) {
                  print('=== SENDING TO RASA ===');
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: BlocListener<STTBloc, STTState>(
                      listener: (context, state) {
                        // Auto-send to NLU when STT is done and has text
                        if (state is STTAutoSendToNLU) {
                          context.read<NLUBloc>().add(
                            NLUSendMessageEvent(state.message),
                          );
                          // Clear the recognized text after sending
                          context.read<STTBloc>().recognizedText = '';
                          _textController.clear();
                        }
                      },
                      child: BlocBuilder<STTBloc, STTState>(
                        builder: (context, state) {
                          // Initialize controller with current STT text if it's different
                          final currentSttText = context
                              .read<STTBloc>()
                              .recognizedText;
                          if (_textController.text != currentSttText &&
                              currentSttText.isNotEmpty) {
                            _textController.text = currentSttText;
                            _textController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: currentSttText.length),
                                );
                          }

                          return TextField(
                            controller: _textController,
                            onChanged: (value) {
                              context.read<STTBloc>().recognizedText = value;
                            },
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Type or speak your message...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14.0,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<STTBloc, STTState>(
                    builder: (context, state) {
                      bool isMicOn = context.read<STTBloc>().isMicOn;
                      return FloatingActionButton(
                        heroTag: 'mic',
                        mini: true,
                        backgroundColor: isMicOn
                            ? Theme.of(context).colorScheme.primary
                            : Colors.red,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          if (!isMicOn) {
                            context.read<STTBloc>().add(STTListenEvent());
                          } else {
                            context.read<STTBloc>().add(
                              STTStopListeningEvent(),
                            );
                          }
                        },
                        child: Icon(isMicOn ? Icons.mic : Icons.mic_off),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'send',
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      final textToSend = _textController.text.trim();
                      if (textToSend.isNotEmpty) {
                        context.read<NLUBloc>().add(
                          NLUSendMessageEvent(textToSend),
                        );
                        // Clear the text after sending
                        context.read<STTBloc>().recognizedText = '';
                        _textController.clear();
                      }
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
