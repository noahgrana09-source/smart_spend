import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onb_data_entity.dart';
import '../repositories/onb_repository.dart';

/// Use case for saving the user's onboarding data (nationality + investor
/// profile).
///
/// Delegates to [OnbRepository.saveData] and returns the persisted
/// [OnbDataEntity] on success.
class SaveDataUseCase extends UseCase<OnbDataEntity, SaveDataParams> {
  /// The onboarding repository.
  final OnbRepository _repository;

  /// Creates a [SaveDataUseCase] with the given [repository].
  SaveDataUseCase(this._repository);

  @override
  Future<Either<Failure, OnbDataEntity>> call(SaveDataParams params) {
    return _repository.saveData(
      nationality: params.nationality,
      investorProfile: params.investorProfile,
    );
  }
}

/// Parameters required for saving the user's onboarding data.
class SaveDataParams extends Equatable {
  /// The user's nationality.
  final String nationality;

  /// The user's investor risk profile.
  final String investorProfile;

  /// Creates [SaveDataParams] with the given [nationality] and
  /// [investorProfile].
  const SaveDataParams({
    required this.nationality,
    required this.investorProfile,
  });

  @override
  List<Object?> get props => [nationality, investorProfile];
}
