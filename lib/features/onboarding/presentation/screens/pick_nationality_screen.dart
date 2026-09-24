import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/main_app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../widgets/onb_adaptive_dropdown.dart';
import 'investor_test_screen.dart';

/// Second onboarding screen: pick a nationality, then push (backable,
/// unlike [GetYouStartedScreen]'s "Start") to [InvestorTestScreen] with
/// the chosen value.
class PickNationalityScreen extends StatefulWidget {
  const PickNationalityScreen({super.key});

  @override
  State<PickNationalityScreen> createState() => _PickNationalityScreenState();
}

class _PickNationalityScreenState extends State<PickNationalityScreen> {
  /// `null` until the user picks one — that's what keeps "Next" disabled.
  String? _nationality;

  /// `country_picker` is already a dependency (used for its data, not its
  /// own picker UI) — `CountryService().getAll()` is a lightweight source
  /// of country names for the dropdown entries.
  late final List<DropdownMenuEntry<String>> _countryEntries = [
    for (final country in CountryService().getAll())
      DropdownMenuEntry(value: country.name, label: country.name),
  ];

  void _next() {
    final nationality = _nationality;
    if (nationality == null) return;
    Navigator.of(context).push<void>(
      PlatformUtils.isCupertino
          ? CupertinoPageRoute(
              builder: (_) => InvestorTestScreen(nationality: nationality),
            )
          : MaterialPageRoute(
              builder: (_) => InvestorTestScreen(nationality: nationality),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.onbPickNationalityTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              OnbAdaptiveDropdown<String>(
                label: l10n.onbNationalityLabel,
                entries: _countryEntries,
                onSelected: (value) => setState(() => _nationality = value),
              ),
              const SizedBox(height: 24),
              MainAppButton(
                label: l10n.onbNextButton,
                onPressed: _nationality == null ? null : _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
