import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:online_journal_local/data/repositories/user_repository.dart';
import 'domain/repositories/journal_repository.dart';
import 'data/repositories/hive_journal_repository.dart';
import 'presentation/cubit/journal_cubit.dart';
import 'data/models/journal_entry_model.dart';
import 'data/models/user_profile_model.dart';
import 'presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {

// 1. Hive Boxes
  // Box for ALL users (The Database)
  final usersBox = await Hive.openBox<UserProfileModel>('users_db');
  // Box for Session (Simple key-value)
  final sessionBox = await Hive.openBox('session_box');

  sl.registerLazySingleton<Box<UserProfileModel>>(() => usersBox);

  // 2. Repository (Injects both boxes)
  sl.registerLazySingleton(() => UserRepository(usersBox, sessionBox));

  // 3. Auth Cubit
  sl.registerFactory(() => AuthCubit(sl()));



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