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
  Future<List<JournalEntry>> getEntries() async {
    // 3. Use 'box' directly (no need to await openBox)
    final entries = box.values.map((model) => model.toEntity()).toList();
    
    // Sort by date, newest first
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    return entries;
  }

  // NOTE: Ensure your Interface uses 'saveEntry' or 'addEntry'. 
  // I matched this to your previous Cubit code which used 'saveEntry'.
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