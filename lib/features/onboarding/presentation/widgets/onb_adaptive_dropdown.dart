import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// Adaptive single-selection dropdown.
///
/// [DropdownMenu] on Android. On iOS there's no dropdown equivalent, but
/// there is a genuinely native answer for "pick one from a list" — a
/// field that opens a [CupertinoPicker] wheel in an action sheet — so
/// this uses that instead of dressing the Material widget up as
/// Cupertino (unlike `AuthTextField`, which has no such native
/// counterpart to reach for).
///
/// [T] only needs `==` to work for matching [initialSelection] against
/// [entries] — [DropdownMenuEntry] is reused as the entry type on both
/// platforms so callers don't need a separate model.
class OnbAdaptiveDropdown<T> extends StatefulWidget {
  const OnbAdaptiveDropdown({
    super.key,
    required this.label,
    required this.entries,
    this.initialSelection,
    required this.onSelected,
  });

  /// Field label shown when nothing is selected (Material) or as a
  /// placeholder (Cupertino).
  final String label;

  final List<DropdownMenuEntry<T>> entries;
  final T? initialSelection;
  final ValueChanged<T?> onSelected;

  @override
  State<OnbAdaptiveDropdown<T>> createState() =>
      _OnbAdaptiveDropdownState<T>();
}

class _OnbAdaptiveDropdownState<T> extends State<OnbAdaptiveDropdown<T>> {
  late T? _selected = widget.initialSelection;

  DropdownMenuEntry<T>? get _selectedEntry {
    for (final entry in widget.entries) {
      if (entry.value == _selected) return entry;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformUtils.isCupertino
        ? _buildCupertino(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    return DropdownMenu<T>(
      label: Text(widget.label),
      initialSelection: widget.initialSelection,
      dropdownMenuEntries: widget.entries,
      expandedInsets: EdgeInsets.zero,
      onSelected: (value) {
        setState(() => _selected = value);
        widget.onSelected(value);
      },
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final selectedEntry = _selectedEntry;
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedEntry?.label ?? widget.label,
                style: TextStyle(
                  color: selectedEntry == null
                      ? CupertinoColors.placeholderText.resolveFrom(context)
                      : null,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 18,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    var pickedIndex = widget.entries.indexWhere(
      (entry) => entry.value == _selected,
    );
    if (pickedIndex < 0) pickedIndex = 0;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(popupContext),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(popupContext).pop(),
                child: Text(l10n.onbDropdownDone),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: pickedIndex,
                ),
                onSelectedItemChanged: (index) => pickedIndex = index,
                children: [
                  for (final entry in widget.entries) Center(child: Text(entry.label)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      final entry = widget.entries[pickedIndex];
      setState(() => _selected = entry.value);
      widget.onSelected(entry.value);
    });
  }
}
