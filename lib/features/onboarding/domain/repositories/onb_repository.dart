import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/onb_data_entity.dart';

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
}
