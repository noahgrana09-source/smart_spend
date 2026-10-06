import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/data/models/user_model.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';

import '../auth_data_mocks.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 1);

  final tUserModel = UserModel(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: tCreatedAt,
  );

  group('UserModel', () {
    group('fromFirebaseUser', () {
      late MockFirebaseUser mockUser;
      late MockUserMetadata mockMetadata;

      setUp(() {
        mockUser = MockFirebaseUser();
        mockMetadata = MockUserMetadata();
      });

      test('should create UserModel from Firebase User with all fields', () {
        when(() => mockUser.uid).thenReturn('123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn('https://photo.url');
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(tCreatedAt);

        final result = UserModel.fromFirebaseUser(mockUser);

        expect(result.uid, '123');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.photoUrl, 'https://photo.url');
        expect(result.isEmailVerified, true);
        expect(result.createdAt, tCreatedAt);
      });

      test('should handle null optional fields from Firebase User', () {
        when(() => mockUser.uid).thenReturn('456');
        when(() => mockUser.email).thenReturn('user@example.com');
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(tCreatedAt);

        final result = UserModel.fromFirebaseUser(mockUser);

        expect(result.uid, '456');
        expect(result.email, 'user@example.com');
        expect(result.displayName, isNull);
        expect(result.photoUrl, isNull);
        expect(result.isEmailVerified, false);
      });

      test('should throw FormatException when Firebase email is null', () {
        when(() => mockUser.uid).thenReturn('789');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(tCreatedAt);

        expect(
          () => UserModel.fromFirebaseUser(mockUser),
          throwsA(isA<FormatException>()),
        );
      });

      test(
        'should throw FormatException when Firebase creationTime is null',
        () {
          when(() => mockUser.uid).thenReturn('999');
          when(() => mockUser.email).thenReturn('user@example.com');
          when(() => mockUser.displayName).thenReturn(null);
          when(() => mockUser.photoURL).thenReturn(null);
          when(() => mockUser.emailVerified).thenReturn(false);
          when(() => mockUser.metadata).thenReturn(mockMetadata);
          when(() => mockMetadata.creationTime).thenReturn(null);

          expect(
            () => UserModel.fromFirebaseUser(mockUser),
            throwsA(isA<FormatException>()),
          );
        },
      );
    });

    group('toFirestore', () {
      test('should serialize to Firestore format with Timestamp', () {
        final result = tUserModel.toFirestore();

        expect(result['email'], 'test@example.com');
        expect(result['displayName'], 'Test User');
        expect(result['photoUrl'], 'https://photo.url');
        expect(result['isEmailVerified'], true);
        expect(result['createdAt'], Timestamp.fromDate(tCreatedAt));
      });

      test('should not include uid in Firestore map', () {
        final result = tUserModel.toFirestore();
        expect(result.containsKey('uid'), false);
      });
    });

    group('toEntity', () {
      test('should convert UserModel to UserEntity with all fields', () {
        final entity = tUserModel.toEntity();

        expect(entity, isA<UserEntity>());
        expect(entity.uid, tUserModel.uid);
        expect(entity.email, tUserModel.email);
        expect(entity.displayName, tUserModel.displayName);
        expect(entity.photoUrl, tUserModel.photoUrl);
        expect(entity.isEmailVerified, tUserModel.isEmailVerified);
        expect(entity.createdAt, tUserModel.createdAt);
      });

      test('should preserve null optional fields in entity conversion', () {
        final model = UserModel(
          uid: '456',
          email: 'user@example.com',
          createdAt: tCreatedAt,
        );

        final entity = model.toEntity();

        expect(entity.displayName, isNull);
        expect(entity.photoUrl, isNull);
        expect(entity.isEmailVerified, false);
        expect(entity.createdAt, tCreatedAt);
      });
    });

    group('fromJson / toJson', () {
      test('should serialize and deserialize correctly', () {
        final json = tUserModel.toJson();
        final fromJson = UserModel.fromJson(json);

        expect(fromJson, tUserModel);
      });

      test('should produce correct JSON keys', () {
        final json = tUserModel.toJson();

        expect(json['uid'], '123');
        expect(json['email'], 'test@example.com');
        expect(json['displayName'], 'Test User');
        expect(json['photoUrl'], 'https://photo.url');
        expect(json['isEmailVerified'], true);
        expect(json.containsKey('createdAt'), true);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final model1 = UserModel(
          uid: '123',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: tCreatedAt,
        );
        final model2 = UserModel(
          uid: '123',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: tCreatedAt,
        );
        expect(model1, model2);
      });

      test('should not be equal when fields differ', () {
        final model1 = UserModel(
          uid: '123',
          email: 'test@example.com',
          createdAt: tCreatedAt,
        );
        final model2 = UserModel(
          uid: '456',
          email: 'test@example.com',
          createdAt: tCreatedAt,
        );
        expect(model1, isNot(model2));
      });
    });
  });
}
