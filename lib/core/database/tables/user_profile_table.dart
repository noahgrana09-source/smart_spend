import 'package:drift/drift.dart';

/// Local cache of the signed-in user's profile. Mirrors the Firestore
/// `users/{uid}` document — written on every successful sign-in/up (see
/// `AuthRepositoryImpl`), though nothing reads it back yet. Only ever
/// holds the single row for whoever is currently signed in on this
/// device; `AuthLocalDataSource.clear()` empties it on sign-out.
class UserProfiles extends Table {
  TextColumn get uid => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isEmailVerified => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}
