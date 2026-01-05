// lib/presentation/screens/journal_wizard_steps/journal_basics_step.dart
import 'package:flutter/material.dart';

class JournalBasicsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;

  const JournalBasicsStep({
    super.key,
    required this.formKey,
    required this.titleController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: titleController,
        decoration: const InputDecoration(
          labelText: 'Entry Title',
          hintText: 'e.g., A rainy Tuesday',
          border: OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
      ),
    );
  }
}