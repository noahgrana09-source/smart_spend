import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/get_current_user_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  final tUser = UserEntity(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  group('GetCurrentUserUseCase', () {
    test('should return UserEntity when user is authenticated', () {
      when(() => mockRepository.getCurrentUser()).thenReturn(tUser);

      final result = useCase();

      expect(result, tUser);
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no user is authenticated', () {
      when(() => mockRepository.getCurrentUser()).thenReturn(null);

      final result = useCase();

      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
