import 'package:flutter/material.dart';
import 'package:voice_reminder/blocs/task/task_bloc.dart';
import 'package:voice_reminder/models/task_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditTaskDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDueDate;
  final String dialogTitle;
  final String id;

  const EditTaskDialog({
    super.key,
    required this.id,
    this.initialTitle,
    this.initialDescription,
    this.initialDueDate,
    this.dialogTitle = 'Edit Task',
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _dueDate;

  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  DateTime? get dueDate => _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _dueDate =
        widget.initialDueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void handleOnSave() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final dueDate = _dueDate ?? DateTime.now();

    if (title.isNotEmpty) {
      // Add task to the TaskBloc
      context.read<TaskBloc>().add(
        TaskUpdateEvent(
          Task(
            id: widget.id,
            title: title,
            description: description,
            dueDate: dueDate,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                alignLabelWithHint:
                    true, // This moves the label to the top left
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              maxLines: 3,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? 'Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}'
                        : 'No Due Date Selected',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    _dueDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (_dueDate != null) {
                      // Update the state to reflect the new due date
                      (context as Element).markNeedsBuild();
                    }
                    _dueDate ??= DateTime.now().add(const Duration(days: 1));
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            handleOnSave();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
