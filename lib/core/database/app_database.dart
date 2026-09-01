import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/user_profile_dao.dart';
import 'tables/user_profile_table.dart';

part 'app_database.g.dart';

/// The app's single Drift/SQLite connection. Tables live in
/// `core/database/tables/`, DAOs in `core/database/daos/`, both wired
/// together in [tables]/[daos] here — Drift generates one database class
/// per physical connection.
@DriftDatabase(tables: [UserProfiles], daos: [UserProfileDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'smart_spend.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
