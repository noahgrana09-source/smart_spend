import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Watches for Google sign-ins completed outside an explicit
/// [AuthRepository.signInWithGoogle] call (the web rendered button).
///
/// Delegates to [AuthRepository.googleSignInEvents].
class WatchGoogleSignInEventsUseCase
    extends StreamUseCase<Either<Failure, UserEntity>, NoParams> {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [WatchGoogleSignInEventsUseCase] with the given [repository].
  WatchGoogleSignInEventsUseCase(this._repository);

  @override
  Stream<Either<Failure, UserEntity>> call(NoParams params) {
    return _repository.googleSignInEvents;
  }
}
