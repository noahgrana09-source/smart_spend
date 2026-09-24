import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/get_current_user_usecase.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/get_local_data_usecase.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/save_data_usecase.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockGetLocalDataUseCase extends Mock implements GetLocalDataUseCase {}

class MockSaveDataUseCase extends Mock implements SaveDataUseCase {}
