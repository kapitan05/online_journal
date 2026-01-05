import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_journal_local/presentation/cubit/auth_cubit.dart';
import 'package:online_journal_local/presentation/cubit/auth_state.dart';
import 'package:online_journal_local/presentation/widgets/journal_entry_card.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import 'add_journal_wizard.dart';
import 'journal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    // 1. Get the current user from AuthCubit
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.email; // We use email as the unique ID

      // 2. Load entries specific to this user immediately
      context.read<JournalCubit>().loadEntries(_currentUserId);
    } else {
      _currentUserId =
          ''; // Fallback (shouldn't happen if auth flow is correct)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get State safely
    final authState = context.read<AuthCubit>().state;

    // Handle the "Just in case" scenario where state isn't ready
    // (This prevents the Red/Black screen crash)

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get user object for personalized greeting
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.firstName}'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: user.profileImagePath != null
                ? FileImage(File(user.profileImagePath!))
                : null,
            child: user.profileImagePath == null
                ? Text(user.firstName[0].toUpperCase()) // Initials if no image
                : null,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ensure we pass the valid _currentUserId
          // ??? handles the split-second delay between "Logged In" and "Data Ready," ensuring _currentUserId
          // is never accessed in an invalid state. ??
          if (_currentUserId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddJournalWizard(userId: _currentUserId),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<JournalCubit, JournalState>(
        builder: (context, state) {
          if (state is JournalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JournalError) {
            return Center(child: Text(state.message));
          }

          if (state is JournalLoaded) {
            if (state.entries.isEmpty) {
              return const Center(
                child: Text('No entries yet. Start writing! ✍️'),
              );
            }
            // Show list of entries
            return ListView.builder(
              itemCount: state.entries.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final entry = state.entries[index];

                // Using our Custom Widget
                return JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalDetailsScreen(entry: entry),
                      ),
                    );
                  },
                  onDelete: () {
                    context
                        .read<JournalCubit>()
                        .deleteEntry(entry.id, _currentUserId);
                  },
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
