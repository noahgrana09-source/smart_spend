import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking whether the signed-in user's email is verified.
///
/// Delegates to [AuthRepository.checkEmailVerified]. Returns `false` (not
/// a [Failure]) when the check succeeds but the email still isn't
/// verified.
class CheckEmailVerifiedUseCase extends UseCase<bool, NoParams> {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [CheckEmailVerifiedUseCase] with the given [repository].
  CheckEmailVerifiedUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.checkEmailVerified();
  }
}
