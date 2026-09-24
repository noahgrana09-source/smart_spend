import 'package:flutter/material.dart';

/// One selectable option of an [OnbQuestionCard].
class OnbQuestionOption<T> {
  const OnbQuestionOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A floating card with a question on top and selectable options below —
/// styled after a Google Forms question, not platform-adaptive (that
/// look is the point, on both Android and iOS).
///
/// [allowMultipleChoice] switches the option indicator between a
/// single-select radio dot and a multi-select checkmark, and whether
/// selecting a new option replaces or toggles the current selection.
class OnbQuestionCard<T> extends StatefulWidget {
  const OnbQuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.onChanged,
    this.allowMultipleChoice = false,
    this.initialSelection,
  });

  final String question;
  final List<OnbQuestionOption<T>> options;

  /// Whether more than one option can be selected at once.
  final bool allowMultipleChoice;

  /// `null` (rather than defaulting to `const []`) because an untyped
  /// empty-list default on a generic constructor parameter is canonicalized
  /// once as `List<Never>` — independent of `T` — which then throws at
  /// runtime the moment anything is added to a `Set` built from it.
  final List<T>? initialSelection;

  /// Called with the full current selection every time it changes.
  final ValueChanged<List<T>> onChanged;

  @override
  State<OnbQuestionCard<T>> createState() => _OnbQuestionCardState<T>();
}

class _OnbQuestionCardState<T> extends State<OnbQuestionCard<T>> {
  late final Set<T> _selected = Set<T>.of(widget.initialSelection ?? const []);

  void _toggle(T value) {
    setState(() {
      if (widget.allowMultipleChoice) {
        if (!_selected.add(value)) _selected.remove(value);
      } else {
        _selected
          ..clear()
          ..add(value);
      }
    });
    widget.onChanged(_selected.toList(growable: false));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final option in widget.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OnbOptionTile(
                  label: option.label,
                  selected: _selected.contains(option.value),
                  allowMultipleChoice: widget.allowMultipleChoice,
                  onTap: () => _toggle(option.value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnbOptionTile extends StatelessWidget {
  const _OnbOptionTile({
    required this.label,
    required this.selected,
    required this.allowMultipleChoice,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool allowMultipleChoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
        ),
        child: Row(
          children: [
            _OnbOptionIndicator(
              selected: selected,
              allowMultipleChoice: allowMultipleChoice,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class _OnbOptionIndicator extends StatelessWidget {
  const _OnbOptionIndicator({
    required this.selected,
    required this.allowMultipleChoice,
  });

  final bool selected;
  final bool allowMultipleChoice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected ? colorScheme.primary : colorScheme.outline;
    const size = 22.0;

    if (allowMultipleChoice) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 2),
          color: selected ? colorScheme.primary : null,
        ),
        child: selected
            ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
            : null,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: size / 2,
                height: size / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }
}
