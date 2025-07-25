import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/blocs/stt/stt_bloc.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
import 'package:voice_reminder/services/task_service.dart';
import 'pages/split_screen_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final taskService = TaskService();
  await taskService.initializeDatabase();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(create: (context) => TaskBloc()),
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
      title: 'Voice Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.orangeAccent,
          primary: Colors.orange,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplitScreenHome(),
    );
  }
}
