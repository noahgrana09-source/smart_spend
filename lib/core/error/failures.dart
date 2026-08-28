import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Follows the functional error handling pattern using dartz [Either].
/// Each failure type represents a specific category of error that can
/// occur during the execution of use cases.
abstract class Failure extends Equatable {
  /// A stable identifier for the specific error, e.g. a Firebase Auth
  /// error code. Required so callers (like the UI layer) always have
  /// something machine-readable to branch on, not just a free-text
  /// [message].
  final String code;

  /// Optional message describing the failure.
  final String message;

  /// Creates a [Failure] with a [code] and an optional [message].
  const Failure({required this.code, this.message = ''});

  @override
  List<Object?> get props => [code, message];
}

/// Failure originating from a server or remote service.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with a [code] and optional [message].
  const ServerFailure({required super.code, super.message});
}

/// Failure originating from Firebase Authentication.
class AuthFailure extends Failure {
  /// Creates an [AuthFailure] with a Firebase error [code] and optional
  /// [message].
  const AuthFailure({required super.code, super.message});
}

/// Failure when Google Sign-In is cancelled or fails.
class GoogleSignInFailure extends Failure {
  /// Creates a [GoogleSignInFailure] with a [code] and optional [message].
  const GoogleSignInFailure({required super.code, super.message});
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with a [code] and optional [message].
  const NetworkFailure({required super.code, super.message});
}

/// Failure reading or writing the user's profile document, even though
/// Firebase Auth itself succeeded.
class UserPersistenceFailure extends Failure {
  /// Creates a [UserPersistenceFailure] with a [code] and optional
  /// [message].
  const UserPersistenceFailure({required super.code, super.message});
}
