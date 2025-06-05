import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_reminder/all_blocs/nlu/nlu_bloc.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isMicOn = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  String responseText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isMicOn,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 1000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isMicOn ? Icons.mic : Icons.mic_none),
        ),
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
                      child: TextField(
                        controller: TextEditingController(text: _text),
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Recognized Text',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          _isMicOn = false;
                          _speech.stop();
                        });
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

  void _listen() async {
    if (!_isMicOn) {
      _text = "";
      bool available = await _speech.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && _isMicOn) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _keepListening();
            });
          }
        },
        onError: (val) {
          debugPrint('Error: ${val.errorMsg}');
        },
      );
      if (available) {
        setState(() => _isMicOn = true);
        _keepListening();
      }
    } else {
      setState(() => _isMicOn = false);
      await _speech.stop();
    }
  }

  void _keepListening() {
    _speech.listen(
      onResult: (val) => setState(() {
        if (val.hasConfidenceRating && val.confidence > 0) {
          _confidence = val.confidence;
          _text = "$_text ${val.recognizedWords}";
        }
      }),
      listenFor: const Duration(seconds: 30),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }
}
