import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/onb_data_entity.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/save_data_usecase.dart';
import 'package:smart_spend/features/onboarding/presentation/providers/onb_providers.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/investor_test_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'onb_presentation_mocks.dart';

void main() {
  late MockSaveDataUseCase saveData;

  setUpAll(() {
    registerFallbackValue(
      const SaveDataParams(nationality: '', investorProfile: ''),
    );
  });

  setUp(() {
    saveData = MockSaveDataUseCase();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [saveDataUseCaseProvider.overrideWithValue(saveData)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: InvestorTestScreen(nationality: 'Argentina'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Answers all 5 questions with the lowest-risk option of each — a
  /// deterministic all-1s score that computes to "conservative".
  Future<void> answerAllConservatively(WidgetTester tester) async {
    for (final label in [
      'More than 7 years',
      'Sell everything to avoid further losses',
      'Preserve my capital',
      'This money is earmarked for a near-term expense',
      "None, I'm new to investing",
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('renders all 5 questions and a disabled Finish button', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(
      find.text(
        "How long do you plan to keep this money invested before you might need it?",
      ),
      findsOneWidget,
    );
    expect(
      find.text("How would you describe your investing experience?"),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Finish'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Finish stays disabled until every question is answered', (
    tester,
  ) async {
    await pumpScreen(tester);

    for (final label in [
      'More than 7 years',
      'Sell everything to avoid further losses',
      'Preserve my capital',
      'This money is earmarked for a near-term expense',
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    var button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Finish'),
    );
    expect(button.onPressed, isNull);

    await tester.ensureVisible(find.text("None, I'm new to investing"));
    await tester.tap(find.text("None, I'm new to investing"));
    await tester.pumpAndSettle();

    button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Finish'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'tapping Finish saves the picked nationality and the computed profile',
    (tester) async {
      when(() => saveData.call(any())).thenAnswer(
        (_) async => const Right(
          OnbDataEntity(nationality: 'Argentina', investorProfile: 'conservative'),
        ),
      );
      await pumpScreen(tester);
      await answerAllConservatively(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
      await tester.pumpAndSettle();

      verify(
        () => saveData.call(
          const SaveDataParams(
            nationality: 'Argentina',
            investorProfile: 'conservative',
          ),
        ),
      ).called(1);
    },
  );

  testWidgets('shows a spinner while saving is in flight', (tester) async {
    final completer = Completer<Either<Failure, OnbDataEntity>>();
    when(() => saveData.call(any())).thenAnswer((_) => completer.future);
    await pumpScreen(tester);
    await answerAllConservatively(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete(
      const Right(
        OnbDataEntity(nationality: 'Argentina', investorProfile: 'conservative'),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('a save failure shows the error message', (tester) async {
    when(() => saveData.call(any())).thenAnswer(
      (_) async =>
          const Left(DatabaseFailure(code: 'unknown-error', message: 'oops')),
    );
    await pumpScreen(tester);
    await answerAllConservatively(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong: oops. Please try again.'),
      findsOneWidget,
    );
  });
}
