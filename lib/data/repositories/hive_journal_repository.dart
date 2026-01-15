import 'package:hive/hive.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../models/journal_entry_model.dart';

class HiveJournalRepository implements JournalRepository {
  // 1. Define the dependency
  final Box<JournalEntryModel> box;

  // 2. Inject the dependency via Constructor
  HiveJournalRepository(this.box);

  @override
  Future<List<JournalEntry>> getEntries(String userId) async {
    return box.values
        .where((entry) =>
            entry.userId ==
            userId) // so to filter by userId entries for specific user
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addEntry(JournalEntry entry) async {
    final model = JournalEntryModel.fromEntity(entry);
    await box.put(entry.id, model);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await box.delete(id);
  }
}
