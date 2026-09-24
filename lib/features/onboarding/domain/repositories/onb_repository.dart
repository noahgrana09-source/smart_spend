import 'package:dartz/dartz.dart';

import '../../../../core/entities/app_user_entity.dart';
import '../../../../core/entities/onb_data_entity.dart';
import '../../../../core/error/failures.dart';

/// Abstract contract for the onboarding repository.
///
/// Defines the onboarding operations available in the domain layer. The
/// data layer must provide a concrete implementation of this interface.
abstract class OnbRepository {
  /// Persists the user's [nationality] and [investorProfile].
  ///
  /// Returns [OnbDataEntity] on success or a [Failure] on error.
  Future<Either<Failure, OnbDataEntity>> saveData({
    required String nationality,
    required String investorProfile,
  });

  /// Returns the currently signed-in user's basic profile.
  ///
  /// Returns [AppUserEntity] on success or a [Failure] on error.
  Future<Either<Failure, AppUserEntity>> getCurrentUser();

  /// Returns the currently signed-in user's onboarding data as already
  /// persisted on this device, or `null` if there's no local row for
  /// them yet (onboarding hasn't been completed on this device).
  ///
  /// Returns `null`/[OnbDataEntity] on success or a [Failure] on error.
  Future<Either<Failure, OnbDataEntity?>> getLocalData();
}
