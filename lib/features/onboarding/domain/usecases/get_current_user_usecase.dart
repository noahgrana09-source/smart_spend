import 'package:dartz/dartz.dart';

import '../../../../core/entities/app_user_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onb_repository.dart';

/// Use case for retrieving the currently signed-in user's basic profile.
///
/// Delegates to [OnbRepository.getCurrentUser]. Screens use this to show
/// the user's name (or email/photo) without reaching into Firebase
/// directly.
class GetCurrentUserUseCase extends UseCase<AppUserEntity, NoParams> {
  /// The onboarding repository.
  final OnbRepository _repository;

  /// Creates a [GetCurrentUserUseCase] with the given [repository].
  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, AppUserEntity>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
