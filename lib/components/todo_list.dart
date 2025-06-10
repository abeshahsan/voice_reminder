import 'package:flutter/material.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 12, // Replace with your actual todo count
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Todo Item ${index + 1}'),
          trailing: IconButton(
            icon: Icon(Icons.delete, size: 20.0),
            color: Colors.red,
            onPressed: () {
              // Handle delete action
            },
          ),
        );
      },
    );
  }
}
