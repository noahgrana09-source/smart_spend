import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/check_email_verified_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/delete_user_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _MockSignInWithEmail extends Mock implements SignInWithEmailUseCase {}

class _MockSignUpWithEmail extends Mock implements SignUpWithEmailUseCase {}

class _MockSignInWithGoogle extends Mock implements SignInWithGoogleUseCase {}

class _MockSignOut extends Mock implements SignOutUseCase {}

class _MockResendEmailVerification extends Mock
    implements ResendEmailVerificationUseCase {}

class _MockCheckEmailVerified extends Mock
    implements CheckEmailVerifiedUseCase {}

class _MockDeleteUser extends Mock implements DeleteUserUseCase {}

void main() {
  late _MockSignInWithEmail signIn;
  late _MockSignUpWithEmail signUp;
  late _MockSignInWithGoogle google;
  late _MockSignOut signOut;
  late _MockResendEmailVerification resendVerification;
  late _MockCheckEmailVerified checkVerified;
  late _MockDeleteUser deleteUser;

  final user = UserEntity(
    uid: 'u1',
    email: 'a@b.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const SignInWithEmailParams(email: '', password: ''),
    );
    registerFallbackValue(
      const SignUpWithEmailParams(name: '', email: '', password: ''),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    signIn = _MockSignInWithEmail();
    signUp = _MockSignUpWithEmail();
    google = _MockSignInWithGoogle();
    signOut = _MockSignOut();
    resendVerification = _MockResendEmailVerification();
    checkVerified = _MockCheckEmailVerified();
    deleteUser = _MockDeleteUser();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        signInWithEmailUseCaseProvider.overrideWithValue(signIn),
        signUpWithEmailUseCaseProvider.overrideWithValue(signUp),
        signInWithGoogleUseCaseProvider.overrideWithValue(google),
        signOutUseCaseProvider.overrideWithValue(signOut),
        resendEmailVerificationUseCaseProvider.overrideWithValue(
          resendVerification,
        ),
        checkEmailVerifiedUseCaseProvider.overrideWithValue(checkVerified),
        deleteUserUseCaseProvider.overrideWithValue(deleteUser),
      ],
    );
    addTearDown(container.dispose);
    // Pin the auto-dispose providers for the duration of the test.
    container.listen(authProvider, (_, _) {}, fireImmediately: true);
    container.listen(appStateProvider, (_, _) {}, fireImmediately: true);
    return container;
  }

  test('successful email sign-in -> global authenticated, feature normal',
      () async {
    when(() => signIn.call(any())).thenAnswer((_) async => Right(user));
    final container = makeContainer();

    await container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a@b.com', password: 'pw');

    expect(container.read(authProvider), const AuthState.normal());
    expect(container.read(appStateProvider), const AppState.authenticated());
  });

  test('feature goes through loading while the use case is in flight',
      () async {
    final completer = Completer<Either<Failure, UserEntity>>();
    when(() => signIn.call(any())).thenAnswer((_) => completer.future);
    final container = makeContainer();

    final future = container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a@b.com', password: 'pw');
    expect(container.read(authProvider), const AuthState.loading());

    completer.complete(Right(user));
    await future;
    expect(container.read(authProvider), const AuthState.normal());
  });

  test('generic failure -> feature error(general), global untouched', () async {
    when(() => signIn.call(any())).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'x', message: 'boom')),
    );
    final container = makeContainer();

    await container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a', password: 'b');

    expect(
      container.read(authProvider),
      const AuthState.error(kind: AuthErrorKind.general, message: 'boom'),
    );
    expect(container.read(appStateProvider), const AppState.unauthenticated());
  });

  test('invalid-credential -> feature error(invalidCredentials)', () async {
    when(() => signIn.call(any())).thenAnswer(
      (_) async => const Left(AuthFailure(code: 'invalid-credential')),
    );
    final container = makeContainer();

    await container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a', password: 'b');

    expect(
      container.read(authProvider),
      const AuthState.error(kind: AuthErrorKind.invalidCredentials),
    );
  });

  test('email-already-in-use via sign-up -> error(emailAlreadyInUse)',
      () async {
    when(() => signUp.call(any())).thenAnswer(
      (_) async => const Left(AuthFailure(code: 'email-already-in-use')),
    );
    final container = makeContainer();

    await container.read(authProvider.notifier).submitSignUp(
          name: 'A',
          email: 'a@b.com',
          password: 'pw',
        );

    expect(
      container.read(authProvider),
      const AuthState.error(kind: AuthErrorKind.emailAlreadyInUse),
    );
  });

  test('cancelled Google prompt -> feature normal, still unauthenticated',
      () async {
    when(() => google.call(any())).thenAnswer(
      (_) async => const Left(GoogleSignInFailure(code: 'canceled')),
    );
    final container = makeContainer();

    await container.read(authProvider.notifier).submitGoogle();

    expect(container.read(authProvider), const AuthState.normal());
    expect(container.read(appStateProvider), const AppState.unauthenticated());
  });

  test('sign-out success -> global unauthenticated', () async {
    when(() => signIn.call(any())).thenAnswer((_) async => Right(user));
    when(() => signOut.call(any())).thenAnswer((_) async => const Right(unit));
    final container = makeContainer();
    await container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a', password: 'b');

    await container.read(authProvider.notifier).submitSignOut();

    expect(container.read(appStateProvider), const AppState.unauthenticated());
    expect(container.read(authProvider), const AuthState.normal());
  });

  test(
    'submitSignOut completes even when nothing watches authProvider',
    () async {
      // The account / onboarding screen calls this fire-and-forget via
      // `ref.read` — it never `ref.watch`es authProvider. With an
      // auto-disposing notifier, it would be collected during this
      // (deliberately slow) await, and the continuation's
      // `ref.read(appStateProvider...)` would throw on a dead ref —
      // AppState would stay `authenticated` and the screen would freeze.
      when(() => signOut.call(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const Right(unit);
      });

      final container = ProviderContainer(
        overrides: [signOutUseCaseProvider.overrideWithValue(signOut)],
      );
      addTearDown(container.dispose);
      container
          .read(appStateProvider.notifier)
          .update(const AppState.authenticated());

      await container.read(authProvider.notifier).submitSignOut();

      expect(
        container.read(appStateProvider),
        const AppState.unauthenticated(),
      );
    },
  );

  test('sign-out failure -> global state unchanged, feature error(general)',
      () async {
    when(() => signIn.call(any())).thenAnswer((_) async => Right(user));
    when(() => signOut.call(any())).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'x', message: 'no network')),
    );
    final container = makeContainer();
    await container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a', password: 'b');

    await container.read(authProvider.notifier).submitSignOut();

    expect(container.read(appStateProvider), const AppState.authenticated());
    expect(
      container.read(authProvider),
      const AuthState.error(
        kind: AuthErrorKind.general,
        message: 'no network',
      ),
    );
  });

  test(
    'successful sign-up -> feature verifying(email), global stays unauthenticated',
    () async {
      when(() => signUp.call(any())).thenAnswer((_) async => Right(user));
      final container = makeContainer();

      await container.read(authProvider.notifier).submitSignUp(
            name: 'A',
            email: 'a@b.com',
            password: 'pw',
          );

      expect(
        container.read(authProvider),
        const AuthState.verifying(email: 'a@b.com'),
      );
      expect(container.read(appStateProvider), const AppState.unauthenticated());
    },
  );

  group('checkEmailVerifiedNow', () {
    test('verified -> global authenticated, feature normal', () async {
      when(() => signUp.call(any())).thenAnswer((_) async => Right(user));
      when(
        () => checkVerified.call(any()),
      ).thenAnswer((_) async => const Right(true));
      final container = makeContainer();
      await container.read(authProvider.notifier).submitSignUp(
            name: 'A',
            email: 'a@b.com',
            password: 'pw',
          );

      await container.read(authProvider.notifier).checkEmailVerifiedNow();

      expect(container.read(authProvider), const AuthState.normal());
      expect(container.read(appStateProvider), const AppState.authenticated());
    });

    test(
      'not verified yet -> feature error(emailNotVerified), global untouched',
      () async {
        when(() => signUp.call(any())).thenAnswer((_) async => Right(user));
        when(
          () => checkVerified.call(any()),
        ).thenAnswer((_) async => const Right(false));
        final container = makeContainer();
        await container.read(authProvider.notifier).submitSignUp(
              name: 'A',
              email: 'a@b.com',
              password: 'pw',
            );

        await container.read(authProvider.notifier).checkEmailVerifiedNow();

        expect(
          container.read(authProvider),
          const AuthState.error(kind: AuthErrorKind.emailNotVerified),
        );
        expect(
          container.read(appStateProvider),
          const AppState.unauthenticated(),
        );
      },
    );

    test('failure -> feature error(general), global untouched', () async {
      when(
        () => checkVerified.call(any()),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(code: 'x', message: 'boom')),
      );
      final container = makeContainer();

      await container.read(authProvider.notifier).checkEmailVerifiedNow();

      expect(
        container.read(authProvider),
        const AuthState.error(kind: AuthErrorKind.general, message: 'boom'),
      );
      expect(container.read(appStateProvider), const AppState.unauthenticated());
    });
  });

  group('resendVerificationEmail', () {
    test('success -> feature normal', () async {
      when(
        () => resendVerification.call(any()),
      ).thenAnswer((_) async => const Right(unit));
      final container = makeContainer();

      await container.read(authProvider.notifier).resendVerificationEmail();

      expect(container.read(authProvider), const AuthState.normal());
    });

    test('failure -> feature error(general)', () async {
      when(() => resendVerification.call(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(code: 'too-many-requests', message: '')),
      );
      final container = makeContainer();

      await container.read(authProvider.notifier).resendVerificationEmail();

      expect(
        container.read(authProvider),
        const AuthState.error(kind: AuthErrorKind.general, message: null),
      );
    });
  });

  group('deleteUser', () {
    test('success -> feature normal', () async {
      when(
        () => deleteUser.call(any()),
      ).thenAnswer((_) async => const Right(unit));
      final container = makeContainer();

      await container.read(authProvider.notifier).deleteUser();

      expect(container.read(authProvider), const AuthState.normal());
    });

    test('failure -> feature error(general)', () async {
      when(() => deleteUser.call(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(code: 'x', message: 'Try again later')),
      );
      final container = makeContainer();

      await container.read(authProvider.notifier).deleteUser();

      expect(
        container.read(authProvider),
        const AuthState.error(
          kind: AuthErrorKind.general,
          message: 'Try again later',
        ),
      );
    });
  });

  group('resumeVerifying', () {
    test('from normal -> feature verifying(email)', () async {
      final container = makeContainer();

      container.read(authProvider.notifier).resumeVerifying(email: 'a@b.com');

      expect(
        container.read(authProvider),
        const AuthState.verifying(email: 'a@b.com'),
      );
    });

    test(
      "doesn't clobber a state other than normal (e.g. a sign-in already "
      'in flight)',
      () async {
        final completer = Completer<Either<Failure, UserEntity>>();
        when(() => signIn.call(any())).thenAnswer((_) => completer.future);
        final container = makeContainer();
        // ignore: unawaited_futures
        container
            .read(authProvider.notifier)
            .submitSignIn(email: 'a@b.com', password: 'pw');
        expect(container.read(authProvider), const AuthState.loading());

        container
            .read(authProvider.notifier)
            .resumeVerifying(email: 'a@b.com');

        expect(container.read(authProvider), const AuthState.loading());
        completer.complete(Right(user));
      },
    );
  });

  test('reset() returns the feature to normal', () async {
    when(() => signIn.call(any())).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'x', message: 'boom')),
    );
    final container = makeContainer();
    await container
        .read(authProvider.notifier)
        .submitSignIn(email: 'a', password: 'b');
    expect(container.read(authProvider), isA<AuthError>());

    container.read(authProvider.notifier).reset();
    expect(container.read(authProvider), const AuthState.normal());
  });
}
