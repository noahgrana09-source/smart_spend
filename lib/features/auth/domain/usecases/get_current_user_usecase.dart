import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for retrieving the currently authenticated user.
///
/// Returns the current [UserEntity] if a user is signed in,
/// or `null` if no user is authenticated. This is a synchronous operation.
class GetCurrentUserUseCase {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [GetCurrentUserUseCase] with the given [repository].
  GetCurrentUserUseCase(this._repository);

  /// Returns the current [UserEntity] or `null`.
  UserEntity? call() {
    return _repository.getCurrentUser();
  }
}
