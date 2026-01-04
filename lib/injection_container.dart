import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// Imports needed for correct types
import 'domain/repositories/journal_repository.dart';
import 'data/repositories/hive_journal_repository.dart';
import 'presentation/cubit/journal_cubit.dart';
import 'data/models/journal_entry_model.dart'; // <--- Make sure to import this!

final sl = GetIt.instance;

Future<void> init() async {
  // ! External (Database)
  final journalBox = await Hive.openBox<JournalEntryModel>('journalBox');
  
  // Register the box with the specific type
  sl.registerLazySingleton<Box<JournalEntryModel>>(() => journalBox);

  // ! Features - Journal
  sl.registerLazySingleton<JournalRepository>(
    // FIX: Add <Box<JournalEntryModel>> so it finds the correct registered object
    () => HiveJournalRepository(sl<Box<JournalEntryModel>>()), 
  );

  sl.registerFactory(() => JournalCubit(sl()));
}