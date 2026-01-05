import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:online_journal_local/data/models/user_profile_model.dart';
import 'package:online_journal_local/presentation/cubit/auth_cubit.dart';
import 'package:online_journal_local/presentation/cubit/auth_state.dart';
import 'package:online_journal_local/presentation/screens/login_screen.dart';

import 'injection_container.dart' as di;
import 'presentation/cubit/journal_cubit.dart';
import 'data/models/journal_entry_model.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // For development: Clear existing boxes to avoid stale data issues
  // await Hive.deleteBoxFromDisk('journalBox');

  // Register Adapters for Hive models
  Hive.registerAdapter(JournalEntryModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());

  await di.init();

  // Just to verify the box path
  // print("📦 Hive Storage Path: ${Hive.box<UserProfileModel>('userBox').path}");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // MultiBlocProvider because we have multiple cubits
      providers: [
        BlocProvider(create: (_) => di.sl<JournalCubit>()),
        // Load AuthCubit and check status immediately by calling checkAuthStatus
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuthStatus()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // Auth Wrapper: Decides what to show
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomeScreen();
            } else if (state is AuthUnauthenticated) {
              return const LoginScreen();
            }
            // Show loading indicator while checking auth status
            if (state is AuthInitial) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            // FOR ALL OTHER STATES (Unauthenticated, Loading, Error) -> Show Login
            // We let LoginScreen handle the Loading/Error UI internally.
            // This prevents LoginScreen from being unmounted during the sign-in process.
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
