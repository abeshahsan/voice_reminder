import 'package:avatar_glow/avatar_glow.dart';
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
  bool _isMicOn = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  String responseText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BlocBuilder<STTBloc, STTState>(
        builder: (context, state) {
          if (state is STTStateListening) {
            _isMicOn = true;
          } else {
            _isMicOn = false;
          }
          debugPrint('Mic is ${_isMicOn ? "ON" : "OFF"}');
          return AvatarGlow(
            animate: _isMicOn,
            glowColor: Theme.of(context).primaryColor,
            duration: const Duration(milliseconds: 1000),
            repeat: true,
            child: FloatingActionButton(
              onPressed: () {
                if (!_isMicOn) {
                  _text = '';
                  context.read<STTBloc>().add(STTListenEvent());
                } else {
                  _text = 'Press the button and start speaking';
                  context.read<STTBloc>().add(STTStopListeningEvent());
                }
              },
              child: Icon(_isMicOn ? Icons.mic : Icons.mic_none),
            ),
          );
        },
      ),
      body: BlocBuilder<NLUBloc, NLUState>(
        builder: (context, state) {
          if (state is NLULoading) {
            return const Center(child: CircularProgressIndicator());
          }
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
                          if (state is STTtextChanged) {
                            _text = "$_text ${state.text}";
                            _confidence = state.confidence;
                          }
                          return TextField(
                            controller: TextEditingController(text: _text),
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Recognized Text',
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
                        if (!_isMicOn) {
                          return;
                        }
                        // Stop listening and send the text to NLU
                        context.read<STTBloc>().add(STTStopListeningEvent());
                        final textToSend = _text;
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
