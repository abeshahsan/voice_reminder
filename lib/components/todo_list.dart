import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
import 'package:voice_reminder/pages/task_form_page.dart';
import 'package:voice_reminder/models/task_model.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading tasks',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(TaskLoadEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<Task> tasks = context.read<TaskBloc>().allTasks;
        if (tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          padding: const EdgeInsets.all(4.0),
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.only(
                left: 16.0,
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
              ),
              title: Text(tasks[index].title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasks[index].description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Due: ${tasks[index].dueDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () async {
                  final value = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(100, 100, 0, 0),
                    items: [
                      PopupMenuItem(
                        value: 'edit',
                        child: const Text('Edit Task'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: const Text('Delete Task'),
                      ),
                    ],
                  );
                  if (!context.mounted) return;
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskFormPage(task: tasks[index]),
                      ),
                    );
                  } else if (value == 'delete') {
                    context.read<TaskBloc>().add(
                      TaskDeleteEvent(tasks[index].id),
                    );
                  }
                },
              ),
              onTap: () {
                // Handle task tap - navigate to edit task
                debugPrint('Tapped on task: ${tasks[index].title}');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskFormPage(task: tasks[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
