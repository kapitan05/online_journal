import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:online_journal_local/domain/repositories/journal_repository.dart';
import 'package:online_journal_local/presentation/cubit/journal_cubit.dart';
import 'package:online_journal_local/presentation/screens/home_screen.dart';
import 'package:online_journal_local/presentation/cubit/auth_cubit.dart';
import 'package:online_journal_local/presentation/cubit/auth_state.dart';
import 'package:online_journal_local/domain/entities/user_profile.dart';

class MockJournalRepository extends Mock implements JournalRepository {}
class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockJournalRepository mockRepo;
  late MockAuthCubit mockAuthCubit;
  late JournalCubit journalCubit;

  setUp(() {
    mockRepo = MockJournalRepository();
    mockAuthCubit = MockAuthCubit();
    journalCubit = JournalCubit(mockRepo);

    // Default Stubs
    when(() => mockRepo.getEntries(any())).thenAnswer((_) async => []);
    when(() => mockRepo.addEntry(any())).thenAnswer((_) async => {});
    
    // Mock Auth State to be 'Authenticated' so HomeScreen renders
    when(() => mockAuthCubit.state).thenReturn(AuthAuthenticated(
      UserProfile(
        firstName: 'Test', lastName: 'User', email: 'test@test.com', 
        password: 'pass', street: '', city: '', zipCode: ''
      )
    ));
  });

  testWidgets('Integration Flow: Add Entry Wizard Navigation', (WidgetTester tester) async {
    // 1. Load HomeScreen wrapped in Providers
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<JournalCubit>.value(value: journalCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // 2. Verify we are on Home Screen (Check for FAB)
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    // 3. Tap FAB to open Wizard
    await tester.tap(fabFinder);
    await tester.pumpAndSettle(); // Wait for animation

    // 4. Verify Wizard Opened (Check for "Basics" title)
    expect(find.text('Basics'), findsOneWidget);

    // 5. Fill Step 1 (Title)
    await tester.enterText(find.widgetWithText(TextFormField, 'Entry Title'), 'Integration Title');
    await tester.pump();

    // 6. Tap Next
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // 7. Verify Step 2 (Thoughts)
    expect(find.text('Thoughts'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'What happened?'), 'Integration Content');

    // 8. Tap Next
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // 9. Verify Step 3 (Review) & Save
    expect(find.text('Review'), findsOneWidget);
    await tester.tap(find.text('FINISH & SAVE'));
    await tester.pumpAndSettle(); // Wait for dialog close

    // 10. Verify we are back on Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // 11. Verify Repository 'addEntry' was actually called!
    verify(() => mockRepo.addEntry(any())).called(1);
  });
}