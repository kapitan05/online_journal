import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_journal_local/domain/entities/journal_entry.dart';
import 'package:online_journal_local/presentation/screens/journal_details_screen.dart';

void main() {
  testWidgets('JournalDetailsScreen displays entry details correctly',
      (WidgetTester tester) async {
    // 1. Create a dummy entry
    final testEntry = JournalEntry(
      id: '123',
      userId: 'u1',
      title: 'My Widget Test',
      content: 'Testing is important',
      date: DateTime(2023, 10, 10, 10, 30),
      mood: 'Happy',
    );

    // 2. Load the widget into the tester
    // We must wrap it in MaterialApp because Scaffold requires it
    await tester.pumpWidget(MaterialApp(
      home: JournalDetailsScreen(entry: testEntry),
    ));

    // 3. Assertions (Check if things exist)

    // Check Title
    expect(find.text('My Widget Test'), findsOneWidget);

    // Check Content
    expect(find.text('Testing is important'), findsOneWidget);

    // Check Mood Emoji (Happy = 😊)
    expect(find.text('😊'), findsOneWidget);

    // Check Date Logic (Simple check for part of the date string)
    expect(find.textContaining('Oct 10, 2023'), findsOneWidget);
  });
}
