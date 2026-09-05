import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}
