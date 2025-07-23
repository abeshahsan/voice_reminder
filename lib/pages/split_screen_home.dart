import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
import 'package:voice_reminder/components/todo_list.dart';
import 'package:voice_reminder/components/voice_assistant_widget.dart';
import 'package:voice_reminder/pages/task_form_page.dart';

class SplitScreenHome extends StatefulWidget {
  const SplitScreenHome({super.key});

  @override
  State<SplitScreenHome> createState() => _SplitScreenHomeState();
}

class _SplitScreenHomeState extends State<SplitScreenHome> {
  final ScrollController _taskScrollController = ScrollController();

  @override
  void dispose() {
    _taskScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Reminder'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TaskFormPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskBloc>().add(TaskLoadEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Task List Section (Top Half)
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Tasks',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const Spacer(),
                        BlocBuilder<TaskBloc, TaskState>(
                          builder: (context, state) {
                            final taskCount = context
                                .read<TaskBloc>()
                                .allTasks
                                .length;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$taskCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocListener<TaskBloc, TaskState>(
                      listener: (context, state) {
                        // This ensures the UI updates when tasks change
                        if (state is TaskLoaded) {
                          // Task list will automatically rebuild due to BlocBuilder in TodoList
                          print('Tasks updated: ${state.tasks.length} tasks');
                        }
                      },
                      child: TodoList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Voice Assistant Section (Bottom Half)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: const VoiceAssistantWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
