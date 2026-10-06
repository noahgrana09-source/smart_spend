import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/theme/app_theme.dart';
import 'package:smart_spend/core/utils/platform_utils.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/providers/common_passwords_provider.dart';
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import '../../features/auth/presentation/auth_presentation_mocks.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  setUp(() => PlatformUtils.isIOSOverride = true);
  tearDown(() => PlatformUtils.isIOSOverride = null);

  test('cupertino theme mirrors the Material theme it is derived from', () {
    final cupertino = AppTheme.cupertino(AppTheme.light);

    expect(cupertino.primaryColor, AppTheme.light.colorScheme.primary);
    expect(
      cupertino.scaffoldBackgroundColor,
      AppTheme.light.colorScheme.surface,
    );
    expect(cupertino.brightness, Brightness.light);
    expect(
      AppTheme.cupertino(AppTheme.dark).brightness,
      Brightness.dark,
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      'iOS buttons use the brand primary and page background ($mode)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              signInWithEmailUseCaseProvider.overrideWithValue(
                MockSignInWithEmailUseCase(),
              ),
              signInWithGoogleUseCaseProvider.overrideWithValue(
                MockSignInWithGoogleUseCase(),
              ),
              commonPasswordsProvider.overrideWith(
                (ref) async => const <String>{},
              ),
            ],
            // Same wiring as main.dart's MaterialApp.router builder.
            child: MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => CupertinoTheme(
                data: AppTheme.cupertino(Theme.of(context)),
                child: child!,
              ),
              home: const LoginScreen(),
            ),
          ),
        );
        await _settle(tester);

        final materialTheme = mode == ThemeMode.dark
            ? AppTheme.dark
            : AppTheme.light;
        final context = tester.element(find.byType(CupertinoButton).first);

        expect(
          CupertinoTheme.of(context).primaryColor,
          materialTheme.colorScheme.primary,
        );
        expect(
          CupertinoTheme.of(context).scaffoldBackgroundColor,
          materialTheme.colorScheme.surface,
        );
      },
    );
  }
}
