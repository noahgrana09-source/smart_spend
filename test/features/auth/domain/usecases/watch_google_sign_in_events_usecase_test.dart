import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/watch_google_sign_in_events_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late WatchGoogleSignInEventsUseCase useCase;
  late MockAuthRepository mockRepository;

  final tUser = UserEntity(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: false,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = WatchGoogleSignInEventsUseCase(mockRepository);
  });

  group('WatchGoogleSignInEventsUseCase', () {
    test('emits the UserEntity results from the repository stream unchanged', () {
      when(
        () => mockRepository.googleSignInEvents,
      ).thenAnswer((_) => Stream.value(Right(tUser)));

      final stream = useCase(const NoParams());

      expect(stream, emits(Right(tUser)));
      verify(() => mockRepository.googleSignInEvents).called(1);
    });

    test('emits the Failure results from the repository stream unchanged', () {
      const failure = GoogleSignInFailure(
        code: 'unknown-error',
        message: 'Something went wrong',
      );
      when(
        () => mockRepository.googleSignInEvents,
      ).thenAnswer((_) => Stream.value(const Left(failure)));

      final stream = useCase(const NoParams());

      expect(stream, emits(const Left(failure)));
      verify(() => mockRepository.googleSignInEvents).called(1);
    });
  });
}
