import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/database/app_database.dart';
import 'package:smart_spend/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_spend/features/auth/data/models/user_model.dart';

import '../auth_data_mocks.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockUserProfileDao mockDao;

  final tUserModel = UserModel(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockDao = MockUserProfileDao();
    dataSource = AuthLocalDataSourceImpl(dao: mockDao);
  });

  setUpAll(() {
    registerFallbackValue(
      UserProfilesCompanion.insert(
        uid: 'fallback',
        email: 'fallback@example.com',
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  });

  group('saveUser', () {
    test('upserts the user as a companion via the DAO', () async {
      when(() => mockDao.saveUser(any())).thenAnswer((_) async {});

      await dataSource.saveUser(tUserModel);

      final captured = verify(() => mockDao.saveUser(captureAny())).captured;
      final companion = captured.single as UserProfilesCompanion;
      expect(companion.uid.value, '123');
      expect(companion.email.value, 'test@example.com');
    });
  });

  group('clear', () {
    test('delegates to the DAO', () async {
      when(() => mockDao.clear()).thenAnswer((_) async {});

      await dataSource.clear();

      verify(() => mockDao.clear()).called(1);
    });
  });
}
