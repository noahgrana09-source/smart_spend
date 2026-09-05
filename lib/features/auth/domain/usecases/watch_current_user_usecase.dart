import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Watches the signed-in user's profile from the local cache.
///
/// Delegates to [AuthRepository.watchCurrentUser].
class WatchCurrentUserUseCase extends StreamUseCase<UserEntity?, NoParams> {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [WatchCurrentUserUseCase] with the given [repository].
  WatchCurrentUserUseCase(this._repository);

  @override
  Stream<UserEntity?> call(NoParams params) {
    return _repository.watchCurrentUser();
  }
}
