import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/local/user_profile_dao.dart';
import '../../features/auth/data/local/user_profile_table.dart';

part 'app_database.g.dart';

/// The app's single Drift/SQLite connection. Feature `data` layers add
/// their tables and DAOs to [tables]/[daos] here, since Drift generates
/// one database class per physical connection — the tables themselves
/// stay defined in each feature, this class just wires them together.
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
