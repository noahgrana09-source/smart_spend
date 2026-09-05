import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base contract for a single-shot use case that can fail. [Success] is
/// what it returns on success, [Params] is its input — use [NoParams]
/// when the use case doesn't need one.
abstract class UseCase<Success, Params> {
  Future<Either<Failure, Success>> call(Params params);
}

/// Base contract for a use case that streams results over time instead of
/// returning once — e.g. watching auth state changes.
abstract class StreamUseCase<Success, Params> {
  Stream<Success> call(Params params);
}

/// Marker params for a use case that takes no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
