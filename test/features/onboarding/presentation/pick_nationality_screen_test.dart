import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/pick_nationality_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PickNationalityScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the title, dropdown and a disabled Next button', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Pick your nationality'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is DropdownMenu), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'picking a nationality enables Next, which pushes InvestorTestScreen',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byWidgetPredicate((w) => w is DropdownMenu));
      await tester.pumpAndSettle();
      // First entry in country_picker's list — always visible without
      // scrolling, so the tap doesn't depend on list order elsewhere.
      await tester.tap(find.text('Afghanistan').last);
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(button.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      // A question from InvestorTestScreen confirms the push landed,
      // and that `nationality` made it through (no crash on a null
      // constructor argument, which `push` would surface immediately).
      expect(
        find.text(
          "How long do you plan to keep this money invested before you might need it?",
        ),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
    },
  );
}
