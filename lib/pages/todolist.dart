import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/components/todo_list.dart';
import 'package:voice_reminder/pages/chatbot.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Reminder'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'addTask',
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
            onPressed: () {
              // go to chat bot page, not dialog

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Chatbot()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
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
              // End of TextField Part
              Expanded(child: TodoList()),
            ],
          );
        },
      ),
    );
  }
}
