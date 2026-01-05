import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getEntries(String userId);
  Future<void> addEntry(JournalEntry entry);
  Future<void> deleteEntry(String id);
}
