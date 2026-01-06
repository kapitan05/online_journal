import 'package:flutter/material.dart';
import '../../domain/entities/journal_entry.dart';

// Put the Card from HomeScreen ListView.builder into its own file.
// This makes  HomeScreen much cleaner and counts as a "Custom Widget"
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap; // Callback for navigation
  final VoidCallback onDelete; // Callback for deletion

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Each entry card with Hero animation for mood emoji
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        // --- THE HERO ANIMATION SOURCE ---
        leading: Hero(
          tag: 'mood_${entry.id}',
          child: CircleAvatar(
            // ignore: deprecated_member_use
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            // 1. FittedBox forces the child to shrink to fit the circle
            child: FittedBox(
              fit: BoxFit.contain,
              // 2. Material provides the "canvas" for the text so it doesn't show yellow lines
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding:
                      const EdgeInsets.all(8.0), // Give it some breathing room
                  child: Text(
                    _getMoodEmoji(entry.mood),
                    style: const TextStyle(
                        fontSize: 24), // Keep font size consistent
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(entry.date),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        // Navigation on Tap
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  // Moved helper methods inside the widget to keep it self-contained
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Sad':
        return '😢';
      case 'Excited':
        return '🤩';
      case 'Tired':
        return '😴';
      default:
        return '😐';
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
