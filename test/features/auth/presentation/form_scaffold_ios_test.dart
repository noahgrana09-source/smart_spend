import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/utils/platform_utils.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/providers/common_passwords_provider.dart';
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'auth_presentation_mocks.dart';

/// Like `pumpAndSettle`, but bounded: `FormScaffold`'s Lottie header
/// loops (`repeat: true`), so the tree never truly settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Forces the iOS branch of `FormScaffold` (Cupertino page scaffold) on the
/// host. The host is never iOS, so without this the Material branch is the
/// only one any test ever renders — which is how the missing Material
/// ancestor on iOS went unnoticed.
void main() {
  setUp(() => PlatformUtils.isIOSOverride = true);
  tearDown(() => PlatformUtils.isIOSOverride = null);

  Future<void> pumpUnderIOS(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signInWithEmailUseCaseProvider.overrideWithValue(
            MockSignInWithEmailUseCase(),
          ),
          signInWithGoogleUseCaseProvider.overrideWithValue(
            MockSignInWithGoogleUseCase(),
          ),
          signUpWithEmailUseCaseProvider.overrideWithValue(
            MockSignUpWithEmailUseCase(),
          ),
          commonPasswordsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('LoginScreen renders its text fields under the iOS branch', (
    tester,
  ) async {
    await pumpUnderIOS(tester, const LoginScreen());

    expect(tester.takeException(), isNull);
    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('RegisterScreen renders its text fields under the iOS branch', (
    tester,
  ) async {
    await pumpUnderIOS(tester, const RegisterScreen());

    expect(tester.takeException(), isNull);
    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });
}
