import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/resolve_current_user_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late ResolveCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResolveCurrentUserUseCase(mockRepository);
  });

  final tUser = UserEntity(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  group('ResolveCurrentUserUseCase', () {
    test('should return UserEntity when a session resolves', () async {
      when(
        () => mockRepository.resolveCurrentUser(),
      ).thenAnswer((_) async => tUser);

      final result = await useCase();

      expect(result, tUser);
      verify(() => mockRepository.resolveCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no session resolves', () async {
      when(
        () => mockRepository.resolveCurrentUser(),
      ).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isNull);
      verify(() => mockRepository.resolveCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
