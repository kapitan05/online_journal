import 'package:flutter/material.dart';
import '../../domain/entities/journal_entry.dart';
// import 'package:intl/intl.dart'; // Add to pubspec.yaml if needed, or use simple formatting

// animation for mood emoji + journal details
class JournalDetailsScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailsScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- THE HERO ANIMATION DESTINATION ---
            // The tag MUST match the one in HomeScreen
            Hero(
              tag: 'mood_${entry.id}',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getMoodEmoji(entry.mood),
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              entry.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              "${entry.date.day}/${entry.date.month}/${entry.date.year} ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Only show if analysis exists
            if (entry.aiAnalysis != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50, // Distinct color for AI
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.purple), // AI Icon
                        SizedBox(width: 8),
                        Text(
                          "AI Insight",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.aiAnalysis!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Content text with a slight fade-in animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Text(
                entry.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
