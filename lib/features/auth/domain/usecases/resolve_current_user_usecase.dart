import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for reliably checking whether a session exists at app
/// startup.
///
/// Unlike [GetCurrentUserUseCase], which reads Firebase Auth's
/// `currentUser` synchronously and can race ahead of its asynchronous
/// session restoration, this resolves only once that restoration has
/// settled. Used once, by `AuthNotifier.restoreSession` before the first
/// frame.
class ResolveCurrentUserUseCase {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [ResolveCurrentUserUseCase] with the given [repository].
  ResolveCurrentUserUseCase(this._repository);

  /// Returns the current [UserEntity] or `null`.
  Future<UserEntity?> call() {
    return _repository.resolveCurrentUser();
  }
}
