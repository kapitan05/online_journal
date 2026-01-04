import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:online_journal_local/data/repositories/user_repository.dart';
import 'package:online_journal_local/presentation/cubit/user_cubit.dart';
import 'domain/repositories/journal_repository.dart';
import 'data/repositories/hive_journal_repository.dart';
import 'presentation/cubit/journal_cubit.dart';
import 'data/models/journal_entry_model.dart';
import 'data/models/user_profile_model.dart';

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

  // ! External (User Profile Box)// 1. Open Box

  
  final userBox = await Hive.openBox<UserProfileModel>('userBox');
  sl.registerLazySingleton<Box<UserProfileModel>>(() => userBox);

  // 2. Repository
  sl.registerLazySingleton(() => UserRepository(sl<Box<UserProfileModel>>()));

  // 3. Cubit
  sl.registerFactory(() => UserCubit(sl()));


}