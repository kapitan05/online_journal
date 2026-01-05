// lib/presentation/screens/journal_wizard_steps/journal_content_step.dart
import 'package:flutter/material.dart';

class JournalContentStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController contentController;

  const JournalContentStep({
    super.key,
    required this.formKey,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: contentController,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'What happened?',
          hintText: 'Start writing...',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (val) =>
            val == null || val.isEmpty ? 'Content cannot be empty' : null,
      ),
    );
  }
}
