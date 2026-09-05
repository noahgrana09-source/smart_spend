import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/database/app_database.dart';
import 'package:smart_spend/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_spend/features/auth/data/models/user_model.dart';

import '../auth_data_mocks.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockUserProfileDao mockDao;

  final tCreatedAt = DateTime(2024, 1, 1);

  final tRow = UserProfile(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: tCreatedAt,
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

  group('watchCurrentUser', () {
    test('emits a UserModel when the DAO has a cached row', () {
      when(() => mockDao.watchCurrentUser()).thenAnswer((_) => Stream.value(tRow));

      final stream = dataSource.watchCurrentUser();

      expect(
        stream,
        emits(
          isA<UserModel>()
              .having((m) => m.uid, 'uid', '123')
              .having((m) => m.email, 'email', 'test@example.com'),
        ),
      );
    });

    test('emits null when the DAO cache is empty', () {
      when(() => mockDao.watchCurrentUser()).thenAnswer((_) => Stream.value(null));

      final stream = dataSource.watchCurrentUser();

      expect(stream, emits(isNull));
    });
  });

  group('getCurrentUser', () {
    test('returns a UserModel when the DAO has a cached row', () async {
      when(() => mockDao.getCurrentUser()).thenAnswer((_) async => tRow);

      final result = await dataSource.getCurrentUser();

      expect(result?.uid, '123');
      expect(result?.email, 'test@example.com');
    });

    test('returns null when the DAO cache is empty', () async {
      when(() => mockDao.getCurrentUser()).thenAnswer((_) async => null);

      final result = await dataSource.getCurrentUser();

      expect(result, isNull);
    });
  });

  group('saveUser', () {
    test('upserts the user as a companion via the DAO', () async {
      when(() => mockDao.saveUser(any())).thenAnswer((_) async {});

      final userModel = UserModel.fromDrift(tRow);
      await dataSource.saveUser(userModel);

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
