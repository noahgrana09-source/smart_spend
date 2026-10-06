import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/app_user_entity.dart';
import 'package:smart_spend/core/entities/onb_data_entity.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/core/widgets/adaptive_progress_indicator.dart';
import 'package:smart_spend/features/onboarding/presentation/providers/onb_providers.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/get_you_started_screen.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/onb_wrapper.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'onb_presentation_mocks.dart';

void main() {
  late MockGetLocalDataUseCase getLocalData;
  late MockGetCurrentUserUseCase getCurrentUser;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getLocalData = MockGetLocalDataUseCase();
    getCurrentUser = MockGetCurrentUserUseCase();
    // GetYouStartedScreen (shown whenever there's no local row) resolves
    // this too — a harmless default so tests that don't care about the
    // greeting don't need to stub it themselves.
    when(() => getCurrentUser.call(any())).thenAnswer(
      (_) async =>
          const Right(AppUserEntity(email: 'a@b.com', displayName: 'Noah')),
    );
  });

  Future<ProviderContainer> pumpWrapper(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        getLocalDataUseCaseProvider.overrideWithValue(getLocalData),
        getCurrentUserUseCaseProvider.overrideWithValue(getCurrentUser),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnbWrapper(),
        ),
      ),
    );
    return container;
  }

  testWidgets(
    'shows a bare loading spinner (not GetYouStartedScreen) before the '
    'boot resolve settles',
    (tester) async {
      final neverCompletes = Completer<Either<Failure, OnbDataEntity?>>();
      addTearDown(() {
        if (!neverCompletes.isCompleted) {
          neverCompletes.complete(const Right(null));
        }
      });
      when(
        () => getLocalData.call(any()),
      ).thenAnswer((_) => neverCompletes.future);

      await pumpWrapper(tester);
      await tester.pump();

      expect(find.byType(GetYouStartedScreen), findsNothing);
      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'a local row already exists -> advances AppState to onboarded and '
    'stays on the spinner',
    (tester) async {
      when(() => getLocalData.call(any())).thenAnswer(
        (_) async => const Right(
          OnbDataEntity(nationality: 'Argentina', investorProfile: 'moderate'),
        ),
      );

      final container = await pumpWrapper(tester);
      await tester.pump();
      await tester.pump();

      expect(container.read(appStateProvider), const AppState.onboarded());
      expect(find.byType(GetYouStartedScreen), findsNothing);
      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('no local row -> shows GetYouStartedScreen', (tester) async {
    when(
      () => getLocalData.call(any()),
    ).thenAnswer((_) async => const Right(null));

    final container = await pumpWrapper(tester);
    await tester.pump();
    await tester.pump();

    expect(find.byType(GetYouStartedScreen), findsOneWidget);
    expect(container.read(appStateProvider), isNot(const AppState.onboarded()));
  });

  testWidgets('a failure reading local data is treated as no local row', (
    tester,
  ) async {
    when(() => getLocalData.call(any())).thenAnswer(
      (_) async =>
          const Left(DatabaseFailure(code: 'unknown-error', message: 'oops')),
    );

    await pumpWrapper(tester);
    await tester.pump();
    await tester.pump();

    expect(find.byType(GetYouStartedScreen), findsOneWidget);
  });
}
