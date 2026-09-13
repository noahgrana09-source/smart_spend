import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/domain/usecases/check_email_verified_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/delete_user_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockResendEmailVerificationUseCase extends Mock
    implements ResendEmailVerificationUseCase {}

class MockCheckEmailVerifiedUseCase extends Mock
    implements CheckEmailVerifiedUseCase {}

class MockDeleteUserUseCase extends Mock implements DeleteUserUseCase {}
