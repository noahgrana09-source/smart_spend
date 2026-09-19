import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/onb_data_entity.dart';
import '../../domain/repositories/onb_repository.dart';
import '../datasources/onb_local_datasource.dart';

/// Concrete implementation of [OnbRepository].
///
/// Delegates to [OnbLocalDataSource] and maps exceptions to domain
/// [Failure] types using [Either] from dartz.
class OnbRepositoryImpl implements OnbRepository {
  /// The local data source for onboarding operations.
  final OnbLocalDataSource _localDataSource;

  /// Creates an [OnbRepositoryImpl] with the given [localDataSource].
  OnbRepositoryImpl({required OnbLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, OnbDataEntity>> saveData({
    required String nationality,
    required String investorProfile,
  }) async {
    try {
      final model = await _localDataSource.saveData(
        nationality: nationality,
        investorProfile: investorProfile,
      );
      return Right(model.toEntity());
    } on OnbLocalDataSourceException catch (e) {
      return Left(DatabaseFailure(code: e.code, message: e.message));
    } on Exception catch (e) {
      return Left(DatabaseFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(code: 'unknown-error', message: e.toString()));
    }
  }
}
