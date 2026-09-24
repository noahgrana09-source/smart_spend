import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/main_app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../providers/onb_notifier.dart';
import '../providers/onb_state.dart';
import '../widgets/onb_question_card.dart';

/// Stable, storage-facing codes for `OnbDataEntity.investorProfile` —
/// English constants regardless of UI locale, since this gets persisted
/// and later read by other features (not just displayed).
const _investorProfileConservative = 'conservative';
const _investorProfileModerate = 'moderate';
const _investorProfileAggressive = 'aggressive';

/// Third and last onboarding screen: the investor risk-profile test,
/// then persists the result via [OnbNotifier.submitSaveData].
///
/// Each [OnbQuestionCard]'s options carry an integer risk point (1 =
/// lowest risk tolerance, 4 = highest). A single-choice question
/// contributes that point directly; a multi-choice one contributes the
/// *average* of its selected points, so it stays on the same
/// per-question 1-4 scale regardless of how many boxes get checked — a
/// question with more checkable options wouldn't otherwise skew the
/// total more than one with a single answer. The overall score is the
/// mean of every question's per-question average, bucketed into three
/// equal thirds of that 1-4 range.
class InvestorTestScreen extends ConsumerStatefulWidget {
  const InvestorTestScreen({super.key, required this.nationality});

  final String nationality;

  @override
  ConsumerState<InvestorTestScreen> createState() => _InvestorTestScreenState();
}

class _InvestorTestScreenState extends ConsumerState<InvestorTestScreen> {
  static const _questionCount = 5;

  /// Question index -> its selected option values. A question only gets
  /// an entry once it's been answered at least once.
  final Map<int, List<int>> _answers = {};

  bool get _allAnswered =>
      _answers.length == _questionCount &&
      _answers.values.every((selection) => selection.isNotEmpty);

  void _onAnswered(int questionIndex, List<int> selection) {
    setState(() => _answers[questionIndex] = selection);
  }

  String _computeInvestorProfile() {
    final perQuestionAverages = _answers.values
        .map(
          (selection) => selection.reduce((a, b) => a + b) / selection.length,
        )
        .toList();
    final score =
        perQuestionAverages.reduce((a, b) => a + b) /
        perQuestionAverages.length;

    if (score <= 2) return _investorProfileConservative;
    if (score <= 3) return _investorProfileModerate;
    return _investorProfileAggressive;
  }

  Future<void> _finish() {
    return ref
        .read(onbProvider.notifier)
        .submitSaveData(
          nationality: widget.nationality,
          investorProfile: _computeInvestorProfile(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onbState = ref.watch(onbProvider);
    final isLoading = onbState is OnbLoading;

    return Scaffold(
      // Reached via `push` (unlike `GetYouStartedScreen`'s replace-style
      // "Start"), so — unlike the other two onboarding screens — this one
      // needs a discoverable way back, not just the OS gesture/button.
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnbQuestionCard<int>(
                question: l10n.onbTestTimeHorizonQuestion,
                options: [
                  OnbQuestionOption(
                    value: 4,
                    label: l10n.onbTestTimeHorizonOption1,
                  ),
                  OnbQuestionOption(
                    value: 3,
                    label: l10n.onbTestTimeHorizonOption2,
                  ),
                  OnbQuestionOption(
                    value: 2,
                    label: l10n.onbTestTimeHorizonOption3,
                  ),
                  OnbQuestionOption(
                    value: 1,
                    label: l10n.onbTestTimeHorizonOption4,
                  ),
                ],
                onChanged: (selection) => _onAnswered(0, selection),
              ),
              const SizedBox(height: 16),
              OnbQuestionCard<int>(
                question: l10n.onbTestMarketDropQuestion,
                options: [
                  OnbQuestionOption(
                    value: 1,
                    label: l10n.onbTestMarketDropOption1,
                  ),
                  OnbQuestionOption(
                    value: 2,
                    label: l10n.onbTestMarketDropOption2,
                  ),
                  OnbQuestionOption(
                    value: 3,
                    label: l10n.onbTestMarketDropOption3,
                  ),
                  OnbQuestionOption(
                    value: 4,
                    label: l10n.onbTestMarketDropOption4,
                  ),
                ],
                onChanged: (selection) => _onAnswered(1, selection),
              ),
              const SizedBox(height: 16),
              OnbQuestionCard<int>(
                question: l10n.onbTestGoalQuestion,
                options: [
                  OnbQuestionOption(value: 1, label: l10n.onbTestGoalOption1),
                  OnbQuestionOption(value: 2, label: l10n.onbTestGoalOption2),
                  OnbQuestionOption(value: 3, label: l10n.onbTestGoalOption3),
                  OnbQuestionOption(value: 4, label: l10n.onbTestGoalOption4),
                ],
                onChanged: (selection) => _onAnswered(2, selection),
              ),
              const SizedBox(height: 16),
              OnbQuestionCard<int>(
                question: l10n.onbTestSituationQuestion,
                allowMultipleChoice: true,
                options: [
                  OnbQuestionOption(
                    value: 1,
                    label: l10n.onbTestSituationOption1,
                  ),
                  OnbQuestionOption(
                    value: 2,
                    label: l10n.onbTestSituationOption2,
                  ),
                  OnbQuestionOption(
                    value: 3,
                    label: l10n.onbTestSituationOption3,
                  ),
                  OnbQuestionOption(
                    value: 4,
                    label: l10n.onbTestSituationOption4,
                  ),
                ],
                onChanged: (selection) => _onAnswered(3, selection),
              ),
              const SizedBox(height: 16),
              OnbQuestionCard<int>(
                question: l10n.onbTestExperienceQuestion,
                options: [
                  OnbQuestionOption(
                    value: 1,
                    label: l10n.onbTestExperienceOption1,
                  ),
                  OnbQuestionOption(
                    value: 2,
                    label: l10n.onbTestExperienceOption2,
                  ),
                  OnbQuestionOption(
                    value: 3,
                    label: l10n.onbTestExperienceOption3,
                  ),
                  OnbQuestionOption(
                    value: 4,
                    label: l10n.onbTestExperienceOption4,
                  ),
                ],
                onChanged: (selection) => _onAnswered(4, selection),
              ),
              const SizedBox(height: 24),
              if (onbState is OnbError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppErrorBanner(
                    message: l10n.onbErrorGeneric(
                      onbState.failure.message.isEmpty
                          ? onbState.failure.code
                          : onbState.failure.message,
                    ),
                  ),
                ),
              MainAppButton(
                label: l10n.onbFinishButton,
                isLoading: isLoading,
                onPressed: _allAnswered && !isLoading ? _finish : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
