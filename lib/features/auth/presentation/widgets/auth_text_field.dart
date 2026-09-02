import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';

/// Adaptive form text field.
///
/// Always a [TextFormField] so it plugs into the screen's [Form] and its
/// [validator] runs on `formKey.currentState!.validate()` — including
/// the re-validate the screens do after a failed submit to surface a
/// server-side error under the field. On iOS it's dressed to resemble a
/// Cupertino rounded field (there's no Cupertino form field that matches
/// this layout); on Android it uses a standard [InputDecoration].
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: PlatformUtils.isCupertino
          ? _cupertinoLikeDecoration(context)
          : InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
    );
  }

  InputDecoration _cupertinoLikeDecoration(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
