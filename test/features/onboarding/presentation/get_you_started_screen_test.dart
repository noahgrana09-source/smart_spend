import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/app_user_entity.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/onboarding/presentation/providers/onb_providers.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/get_you_started_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'onb_presentation_mocks.dart';

/// Like `pumpAndSettle`, but bounded: the Lottie animation between the
/// greeting and the button loops (`repeat: true`), so the tree never
/// truly settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  late MockGetCurrentUserUseCase getCurrentUser;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getCurrentUser = MockGetCurrentUserUseCase();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getCurrentUserUseCaseProvider.overrideWithValue(getCurrentUser),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GetYouStartedScreen(),
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('renders the greeting with the current user\'s name', (
    tester,
  ) async {
    when(() => getCurrentUser.call(any())).thenAnswer(
      (_) async =>
          const Right(AppUserEntity(email: 'noah@example.com', displayName: 'Noah')),
    );

    await pumpScreen(tester);

    expect(find.textContaining('Noah'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start'), findsOneWidget);
  });

  testWidgets(
    'tapping Start replaces this screen with PickNationalityScreen',
    (tester) async {
      when(() => getCurrentUser.call(any())).thenAnswer(
        (_) async =>
            const Right(AppUserEntity(email: 'noah@example.com', displayName: 'Noah')),
      );

      await pumpScreen(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Start'));
      await _settle(tester);

      expect(find.text('Pick your nationality'), findsOneWidget);
      // Replaced, not pushed: nothing to pop back to.
      expect(find.byType(BackButton), findsNothing);
    },
  );
}
