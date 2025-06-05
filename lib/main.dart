import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/all_blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/all_blocs/stt/stt_bloc.dart';
import 'pages/speech.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NLUBloc>(create: (context) => NLUBloc()),
        BlocProvider<STTBloc>(create: (context) => STTBloc()),
      ],
      child: const MyApp(),
    ),
  );
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
