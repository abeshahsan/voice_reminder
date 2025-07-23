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
      resizeToAvoidBottomInset: true,
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final bool keyboardVisible = keyboardHeight > 0;
            final availableHeight = constraints.maxHeight;

            // When keyboard is visible, give more space to voice assistant
            // When keyboard is hidden, split more evenly
            final taskListFlex = keyboardVisible ? 2 : 3;
            final voiceAssistantFlex = keyboardVisible ? 3 : 2;

            return Column(
              children: [
                // Task List Section
                Expanded(
                  flex: taskListFlex,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header - only show if we have enough space
                        if (availableHeight > 400 || !keyboardVisible)
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
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
                        // Task List
                        Expanded(
                          child: BlocListener<TaskBloc, TaskState>(
                            listener: (context, state) {
                              if (state is TaskLoaded) {
                                print(
                                  'Tasks updated: ${state.tasks.length} tasks',
                                );
                              }
                            },
                            child: const TodoList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Voice Assistant Section
                Expanded(
                  flex: voiceAssistantFlex,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: VoiceAssistantWidget(showHeader: !keyboardVisible),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
