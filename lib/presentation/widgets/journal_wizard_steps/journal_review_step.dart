// lib/presentation/screens/journal_wizard_steps/journal_review_step.dart
import 'package:flutter/material.dart';

class JournalReviewStep extends StatelessWidget {
  final String selectedMood;
  final List<String> moods;
  final ValueChanged<String?> onMoodChanged;
  final String title;
  final String content;

  const JournalReviewStep({
    super.key,
    required this.selectedMood,
    required this.moods,
    required this.onMoodChanged,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How did you feel?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedMood,
          isExpanded: true,
          items: moods.map((String mood) {
            return DropdownMenuItem<String>(
              value: mood,
              child: Text(mood),
            );
          }).toList(),
          onChanged: onMoodChanged,
        ),
        const SizedBox(height: 20),
        const Divider(),
        const Text('Summary:', style: TextStyle(color: Colors.grey)),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
