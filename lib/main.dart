import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
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
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isMicOn ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _text),
                    readOnly: true,
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
                  onPressed: () async {
                    setState(() {
                      _isMicOn = false;
                      _speech.stop();
                    });
                    final textToSend = _text;
                    final response = await fetchAndPrintResponse(textToSend);
                    setState(() {
                      responseText = response;
                    });
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
          print('Error: ${val.errorMsg}');
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

  Future<String> fetchAndPrintResponse(String text) async {
    print("lol");
    http.Response response = await http.post(
      Uri.parse(
        'http://192.168.0.108:5005/model/parse',
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
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch response: ${response.statusCode}');
    }
  }
}


/**
 * initial commit
 * 
 * - added a simple UI with speech to text functionality
 * - added a python backend with 'Rasa NLU' for intent classification and entity extraction
 * 
 */