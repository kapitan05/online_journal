import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:online_journal_local/domain/entities/journal_entry.dart';
import 'package:online_journal_local/domain/repositories/journal_repository.dart';
import 'package:online_journal_local/presentation/cubit/journal_cubit.dart';
import 'package:online_journal_local/presentation/cubit/journal_state.dart';

// 1. Create a Mock Repository
class MockJournalRepository extends Mock implements JournalRepository {}

void main() {
  late JournalCubit cubit;
  late MockJournalRepository mockRepo;

  // 2. Setup reusable data
  final testEntry = JournalEntry(
    id: '1',
    userId: 'user1',
    title: 'Test Title',
    content: 'Test Content',
    date: DateTime.now(),
    mood: 'Happy',
  );

  setUp(() {
    mockRepo = MockJournalRepository();
    cubit = JournalCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('JournalCubit Unit Tests', () {
    // Test 1: Initial State
    test('initial state is JournalInitial', () {
      expect(cubit.state, isA<JournalInitial>());
    });

    // Test 2: Load Entries Success
    blocTest<JournalCubit, JournalState>(
      'emits [JournalLoading, JournalLoaded] when entries are loaded successfully',
      build: () {
        // Arrange: Tell the mock what to return when called
        when(() => mockRepo.getEntries(any()))
            .thenAnswer((_) async => [testEntry]);
        return cubit;
      },
      act: (cubit) => cubit.loadEntries('user1'),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalLoaded>()
            .having((state) => state.entries.first, 'entry', testEntry),
      ],
    );

    // Test 3: Load Entries Failure
    blocTest<JournalCubit, JournalState>(
      'emits [JournalLoading, JournalError] when loading fails',
      build: () {
        when(() => mockRepo.getEntries(any()))
            .thenThrow(Exception('Database error'));
        return cubit;
      },
      act: (cubit) => cubit.loadEntries('user1'),
      expect: () => [
        isA<JournalLoading>(),
        isA<JournalError>(),
      ],
    );
  });
}
