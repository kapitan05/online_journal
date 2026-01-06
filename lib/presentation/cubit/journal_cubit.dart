import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/entities/journal_entry.dart';
import 'journal_state.dart';

// Import the service
import 'package:online_journal_local/data/services/gemini_service.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository repository;
  final GeminiService geminiService; // Store the service

  // Update accepts actual GeminiService instead
  JournalCubit(this.repository, this.geminiService) : super(JournalInitial());

  // Load all entries
  Future<void> loadEntries(String userId) async {
    emit(JournalLoading());
    try {
      final entries = await repository.getEntries(userId);
      emit(JournalLoaded(entries));
    } catch (e) {
      emit(JournalError("Failed to load entries: $e"));
    }
  }

  // 2. Add Entry (adjusted to use AI)
  // production version with AI integration
  Future<void> addEntry(
      String title, String content, String mood, String userId) async {
    try {
      // AI LOGIC START
      // Call Gemini to get analysis before saving.
      // We await it here, but inside a try/catch so if AI fails, we get null.
      String? analysis;
      try {
        analysis = await geminiService.analyzeJournal(title, content, mood);
      } catch (e) {
        // If AI fails (e.g. no internet), we just continue without analysis
        // preventing the whole save from failing.
        analysis = null;
      }
      // AI LOGIC END

      final newEntry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        content: content,
        date: DateTime.now(),
        mood: mood,
        aiAnalysis: analysis, // Save the analysis to the entity
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
