import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';

/// Adaptive form text field.
///
/// Always a [TextFormField] so it plugs into the screen's [Form]. There's
/// no as-you-type validation (bad UX to redden a field on the first
/// keystroke) — [validator] runs only when the screen calls
/// `formKey.currentState!.validate()` on submit, and again after a failed
/// submit to surface a server-side error under the field. On iOS it's
/// dressed to resemble a Cupertino rounded field (there's no Cupertino
/// form field that matches this layout); on Android it uses a standard
/// [InputDecoration].
///
/// With [enablePassword] the field owns its obscured state and shows an
/// eye toggle in the suffix (this overrides [obscureText]).
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.enablePassword = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;

  /// Renders a show/hide eye button in the suffix and starts obscured.
  /// Takes precedence over [obscureText].
  final bool enablePassword;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  static const double _cornerRadius = 12;

  late bool _obscured = widget.enablePassword || widget.obscureText;

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    var decoration = PlatformUtils.isCupertino
        ? _cupertinoLikeDecoration(context)
        : InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(_cornerRadius)),
            ),
          );

    if (widget.enablePassword) {
      decoration = decoration.copyWith(
        suffixIcon: IconButton(
          onPressed: _toggleObscured,
          icon: Icon(
            _obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: decoration,
      autovalidateMode: AutovalidateMode.onUnfocus,
    );
  }

  InputDecoration _cupertinoLikeDecoration(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_cornerRadius),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      labelText: widget.label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_cornerRadius),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
