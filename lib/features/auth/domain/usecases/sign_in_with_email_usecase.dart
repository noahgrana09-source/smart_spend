import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password.
///
/// Delegates to [AuthRepository.signInWithEmailAndPassword] and returns
/// the authenticated [UserEntity] on success.
class SignInWithEmailUseCase
    extends UseCase<UserEntity, SignInWithEmailParams> {
  /// The authentication repository.
  final AuthRepository _repository;

  /// Creates a [SignInWithEmailUseCase] with the given [repository].
  SignInWithEmailUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) {
    return _repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters required for signing in with email and password.
class SignInWithEmailParams extends Equatable {
  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Creates [SignInWithEmailParams] with the given [email] and [password].
  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
