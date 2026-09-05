import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/watch_current_user_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late WatchCurrentUserUseCase useCase;
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
    useCase = WatchCurrentUserUseCase(mockRepository);
  });

  group('WatchCurrentUserUseCase', () {
    test('emits the UserEntity results from the repository stream unchanged', () {
      when(
        () => mockRepository.watchCurrentUser(),
      ).thenAnswer((_) => Stream.value(tUser));

      final stream = useCase(const NoParams());

      expect(stream, emits(tUser));
      verify(() => mockRepository.watchCurrentUser()).called(1);
    });

    test('emits null when the repository has nothing cached', () {
      when(
        () => mockRepository.watchCurrentUser(),
      ).thenAnswer((_) => Stream.value(null));

      final stream = useCase(const NoParams());

      expect(stream, emits(isNull));
      verify(() => mockRepository.watchCurrentUser()).called(1);
    });
  });
}
