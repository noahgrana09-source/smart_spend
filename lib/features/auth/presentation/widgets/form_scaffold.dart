import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

/// Shared chrome for the login and register forms: a platform-native
/// page scaffold with a scrollable, keyboard-safe, width-capped body,
/// a header Lottie animation, and a [LoadingOverlay] wired to the shared
/// [authProvider] so any in-flight submit blocks the whole screen.
class FormScaffold extends ConsumerWidget {
  const FormScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showAnimation = true,
  });

  final String title;
  final Widget child;

  /// The header animation plays once on entry ("unlock"). Register can
  /// pass `false` if the extra height crowds its taller form.
  final bool showAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider) is AuthLoading;

    final body = SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showAnimation) ...[
                      Lottie.asset(
                        'assets/animations/Unlocked.json',
                        height: 240,
                        repeat: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                    child,
                  ],
                ),
              ),
            ),
          ),
          LoadingOverlay(visible: isLoading),
        ],
      ),
    );

    if (PlatformUtils.isCupertino) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CupertinoPageScaffold(
          // CupertinoNavigationBar centers `middle` by default.
          navigationBar: CupertinoNavigationBar(middle: Text(title)),
          // The form's fields are Material `TextFormField`s (see
          // `AuthTextField`), and they throw without a Material ancestor.
          // Transparent, so it doesn't change how the Cupertino page looks.
          child: Material(type: MaterialType.transparency, child: body),
        ),
      );
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: body,
      ),
    );
  }
}
