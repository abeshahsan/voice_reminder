import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
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
              subtitle: Text(
                tasks[index].description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                tasks[index].dueDate.toLocal().toString().split(' ')[0],
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                // Handle task tap, e.g., navigate to task details
                debugPrint('Tapped on task: ${tasks[index].title}');
              },
            );
          },
        );
      },
    );
  }
}
