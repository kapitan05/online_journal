import 'package:hive/hive.dart';
import '../../domain/entities/journal_entry.dart';

part 'journal_entry_model.g.dart';

@HiveType(typeId: 0)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String mood;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6) 
  final String userId;

  JournalEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.userId,
    this.imagePath,
  });

  // Convert model to domain entity
  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      title: title,
      content: content,
      date: date,
      mood: mood,
      imagePath: imagePath,
      userId: userId,
    );
  }

  // Create model from domain entity
  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      mood: entry.mood,
      imagePath: entry.imagePath,
      userId: entry.userId,
    );
  }
}
