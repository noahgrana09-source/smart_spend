import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Contract every feature repository follows for offline-first
/// persistence: Drift (local/SQLite) is the single source of truth for
/// reads, Firestore is the remote copy used for backup and multi-device
/// sync, as described in `context/CLAUDE.md`.
///
/// This class only shapes the flow — it has no `drift` or
/// `cloud_firestore` dependency. Each feature's `data` layer implements
/// it against its own Drift table/DAO and Firestore collection.
abstract class SyncRepository<T> {
  /// Streams [T] from the local database. The app never reads Firestore
  /// directly — Drift is always the source for the UI.
  Stream<List<T>> watchAll();

  /// Persists [entity] locally first, then attempts to push it to
  /// Firestore. A remote push failure must not fail the local write; how
  /// the entity gets marked for a later retry (e.g. a `dirty` column) is
  /// left to the implementation.
  Future<Either<Failure, T>> save(T entity);

  /// Deletes [id] locally first, then attempts the same on Firestore.
  Future<Either<Failure, void>> delete(String id);

  /// Fetches from Firestore and seeds the local database. Used for
  /// reconciliation — e.g. login on a new device, or local data missing.
  Future<Either<Failure, void>> pullFromRemote();
}
