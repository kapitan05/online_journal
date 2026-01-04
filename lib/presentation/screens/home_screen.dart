import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import 'add_journal_wizard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Journal'),
        centerTitle: true,
      ),
      // FAB navigates to the Add Screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJournalWizard()),
          );
        },
        child: const Icon(Icons.add),
      ),
      // BlocBuilder listens to state changes
      body: BlocBuilder<JournalCubit, JournalState>(
        builder: (context, state) {
          
          // State 1: Loading
          if (state is JournalLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // State 2: Error
          if (state is JournalError) {
            return Center(child: Text(state.message));
          }
          
          // State 3: Loaded (Success)
          if (state is JournalLoaded) {
            if (state.entries.isEmpty) {
              return const Center(
                child: Text('No entries yet. Start writing! ✍️'),
              );
            }

            return ListView.builder(
              itemCount: state.entries.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final entry = state.entries[index];
                
                // Card UI for each Journal Entry
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      child: const Text('😊'), // Placeholder for Mood Emoji
                    ),
                    title: Text(
                      entry.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(entry.date),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        // Delete action
                        context.read<JournalCubit>().deleteEntry(entry.id);
                      },
                    ),
                    onTap: () {
                      // Later: Add "View Details" screen here
                    },
                  ),
                );
              },
            );
          }

          // State 4: Initial (Just in case)
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Simple date formatter to avoid extra dependencies for now
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}