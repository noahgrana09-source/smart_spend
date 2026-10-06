import 'package:drift/drift.dart';

/// Local cache of the signed-in user's onboarding data (nationality +
/// investor profile), keyed by their Firebase Auth `uid`. Written by
/// `OnbLocalDataSourceImpl.saveData` and never by `auth` — `auth`
/// deliberately keeps no local persistence of its own (see
/// `AuthRepositoryImpl`'s doc comment). Only ever holds the single row for
/// whoever is currently signed in on this device.
class UserProfiles extends Table {
  TextColumn get uid => text()();
  TextColumn get nationality => text()();
  TextColumn get investorProfile => text()();

  @override
  Set<Column> get primaryKey => {uid};
}
