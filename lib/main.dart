import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'injection_container.dart' as di; 
import 'presentation/cubit/journal_cubit.dart';
import 'data/models/journal_entry_model.dart';

// NEW: Import the real Home Screen
import 'presentation/screens/home_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryModelAdapter());

  await di.init(); 

  print("📦 Hive Storage Path: ${Hive.box<JournalEntryModel>('journalBox').path}");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<JournalCubit>()..loadEntries(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true, // Modern UI look
        ),
        home: const HomeScreen(), // Using the real screen
      ),
    );
  }
}