import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
import 'package:voice_reminder/components/edit_task_dialog.dart';
import 'package:voice_reminder/models/task_model.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
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
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            return ListTile(
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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return EditTaskDialog(
                          initialTitle: tasks[index].title,
                          id: tasks[index].id,
                          initialDescription: tasks[index].description,
                          initialDueDate: tasks[index].dueDate,
                        );
                      },
                    );
                  } else if (value == 'delete') {
                    context.read<TaskBloc>().add(TaskDeleteEvent(tasks[index].id));
                  }
                },
              ),
              onTap: () {
                // Handle task tap, e.g., navigate to task details
                debugPrint('Tapped on task: ${tasks[index].title}');
                // for now, open the edit dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return EditTaskDialog(
                      initialTitle: tasks[index].title,
                      id: tasks[index].id,
                      initialDescription: tasks[index].description,
                      initialDueDate: tasks[index].dueDate,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
