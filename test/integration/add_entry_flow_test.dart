import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:online_journal_local/data/services/gemini_service.dart';
import 'package:online_journal_local/domain/entities/journal_entry.dart';
import 'package:online_journal_local/domain/repositories/journal_repository.dart';
import 'package:online_journal_local/presentation/cubit/journal_cubit.dart';
import 'package:online_journal_local/presentation/screens/home_screen.dart';
import 'package:online_journal_local/presentation/cubit/auth_cubit.dart';
import 'package:online_journal_local/presentation/cubit/auth_state.dart';
import 'package:online_journal_local/domain/entities/user_profile.dart';

// Mocks
class MockJournalRepository extends Mock implements JournalRepository {}

class MockGeminiService extends Mock implements GeminiService {}

class MockAuthCubit extends Mock implements AuthCubit {}

// Fake Entry for fallback
class FakeJournalEntry extends Fake implements JournalEntry {}

void main() {
  late MockJournalRepository mockRepo;
  late MockAuthCubit mockAuthCubit;
  late MockGeminiService mockGemini;
  late JournalCubit journalCubit;

  setUpAll(() {
    // Register fallback values for Mocktail if needed
    registerFallbackValue(FakeJournalEntry());
  });

  setUp(() {
    mockRepo = MockJournalRepository();
    mockAuthCubit = MockAuthCubit();
    mockGemini = MockGeminiService();
    journalCubit = JournalCubit(mockRepo, mockGemini);

    // Stub: Get Entries returns empty list initially
    when(() => mockRepo.getEntries(any())).thenAnswer((_) async => []);

    // Stub: Add Entry returns void
    when(() => mockRepo.addEntry(any())).thenAnswer((_) async {});

    // Stub: Gemini Service returns a dummy analysis
    when(() => mockGemini.analyzeJournal(any(), any(), any()))
        .thenAnswer((_) async => "Nice journal entry!");

    // Stub: Auth State is Authenticated (Required for HomeScreen to load)
    when(() => mockAuthCubit.state).thenReturn(AuthAuthenticated(UserProfile(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@test.com',
        password: 'pass',
        street: '',
        city: '',
        zipCode: '')));

    // Stub: Stream for AuthCubit (Crucial if any widget listens to the stream)
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    journalCubit.close();
  });

  testWidgets('Integration Flow: Add Entry Wizard Navigation',
      (WidgetTester tester) async {
    // 1. Set Screen Size (Phone dimensions) to ensure buttons are visible
    tester.view.physicalSize = const Size(2400, 3200);
    tester.view.devicePixelRatio = 3.0;

    // 2. Load HomeScreen
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<JournalCubit>.value(value: journalCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // 3. Verify on Home Screen & Tap FAB
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle(); // Wait for navigation animation

    // --- STEP 1: BASICS ---
    expect(find.text('Basics'), findsOneWidget);

    // Enter Title
    final titleField = find.widgetWithText(TextFormField, 'Entry Title');
    await tester.enterText(titleField, 'Integration Title');
    await tester.pump();

    // Tap Next (Scroll to it first to be safe)
    final nextBtn1 = find.text('NEXT');
    await tester.ensureVisible(nextBtn1);
    await tester.tap(nextBtn1);
    await tester.pumpAndSettle();

    // --- STEP 2: THOUGHTS ---
    // Verify using CONTENT label, not header (Headers are always visible in horizontal steppers)
    expect(find.text('What happened?'), findsOneWidget);

    // Enter Content
    final contentField = find.widgetWithText(TextFormField, 'What happened?');
    await tester.enterText(contentField, 'Integration Content');
    await tester.pump();

    // Tap Next
    final nextBtn2 = find.text('NEXT');
    await tester.ensureVisible(nextBtn2);
    await tester.tap(nextBtn2);
    await tester.pumpAndSettle();

    // --- STEP 3: REVIEW ---
    expect(find.text('Review'), findsOneWidget); // Header
    expect(find.text('Summary:'), findsOneWidget); // Content unique to Step 3

    // Tap Finish
    final finishBtn = find.text('FINISH & SAVE');
    await tester.ensureVisible(finishBtn);
    await tester.tap(finishBtn);
    await tester.pumpAndSettle();

    // --- VERIFICATION ---
    // 1. Check we are back on Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);

    // 2. Check Repository was called with correct data
    verify(() => mockRepo.addEntry(any(
            that: isA<JournalEntry>()
                .having((e) => e.title, 'title', 'Integration Title')
                .having((e) => e.content, 'content', 'Integration Content'))))
        .called(1);

    // Reset view size after test
    addTearDown(tester.view.resetPhysicalSize);
  });
}
