import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for deleting the currently signed-in user's account.
///
/// Delegates to [AuthRepository.deleteUser]. Used to clean up an
/// unverified account the user is abandoning — see `AuthNotifier.deleteUser`.
class DeleteUserUseCase extends UseCase<Unit, NoParams> {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [DeleteUserUseCase] with the given [repository].
  DeleteUserUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.deleteUser();
  }
}
