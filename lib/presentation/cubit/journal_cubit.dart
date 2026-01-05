import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/entities/journal_entry.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository repository;

  // We ask for the repository in the constructor
  JournalCubit(this.repository) : super(JournalInitial());

  // 1. Load all entries
  Future<void> loadEntries(String userId) async {
    emit(JournalLoading());
    try {
      final entries = await repository.getEntries(userId);
      emit(JournalLoaded(entries));
    } catch (e) {
      emit(JournalError("Failed to load entries: $e"));
    }
  }

  Future<void> addEntry(String title, String content, String mood, String userId) async {
    try {
      final newEntry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        content: content,
        date: DateTime.now(),
        mood: mood, // <--- Use the passed mood instead of hardcoded 'Neutral'
      );

      await repository.addEntry(newEntry);
      
      loadEntries(userId); 
    } catch (e) {
      emit(JournalError("Failed to add entry: $e"));
    }
  }
  
  // 3. Delete an entry
  Future<void> deleteEntry(String id, String userId) async {
    try {
      await repository.deleteEntry(id);
      loadEntries(userId);
    } catch (e) {
      emit(const JournalError("Failed to delete entry"));
    }
  }
}