import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
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

void main() {
  late _MockSignInWithEmail signIn;
  late _MockSignUpWithEmail signUp;
  late _MockSignInWithGoogle google;
  late _MockSignOut signOut;

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
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        signInWithEmailUseCaseProvider.overrideWithValue(signIn),
        signUpWithEmailUseCaseProvider.overrideWithValue(signUp),
        signInWithGoogleUseCaseProvider.overrideWithValue(google),
        signOutUseCaseProvider.overrideWithValue(signOut),
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
