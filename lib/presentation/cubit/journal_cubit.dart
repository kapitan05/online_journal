import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/entities/journal_entry.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository repository;

  // We ask for the repository in the constructor
  JournalCubit(this.repository) : super(JournalInitial());

  // 1. Load all entries
  Future<void> loadEntries() async {
    emit(JournalLoading());
    try {
      final entries = await repository.getEntries();
      emit(JournalLoaded(entries));
    } catch (e) {
      emit(JournalError("Failed to load entries: $e"));
    }
  }

  // 2. Add a new entry
  Future<void> addEntry(String title, String content) async {
    try {
      // Create the entity
      final newEntry = JournalEntry(
        id: DateTime.now().toString(), // Simple ID generation
        title: title,
        content: content,
        date: DateTime.now(),
        mood: 'Neutral', // Default mood for now
      );

      await repository.addEntry(newEntry);
      
      // Reload the list so the UI updates
      loadEntries(); 
    } catch (e) {
      emit(JournalError("Failed to add entry: $e"));
    }
  }
  
  // 3. Delete an entry
  Future<void> deleteEntry(String id) async {
    try {
      await repository.deleteEntry(id);
      loadEntries();
    } catch (e) {
      emit(const JournalError("Failed to delete entry"));
    }
  }
}