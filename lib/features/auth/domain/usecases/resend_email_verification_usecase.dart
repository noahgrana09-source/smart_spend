import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for re-sending the verification email to the signed-in user.
///
/// Delegates to [AuthRepository.resendEmailVerification].
class ResendEmailVerificationUseCase extends UseCase<Unit, NoParams> {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [ResendEmailVerificationUseCase] with the given [repository].
  ResendEmailVerificationUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.resendEmailVerification();
  }
}
