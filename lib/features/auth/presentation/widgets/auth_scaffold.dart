import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

/// Shared chrome for the login and register screens: a platform-native
/// page scaffold with a scrollable, keyboard-safe, width-capped body,
/// and a [LoadingOverlay] wired to the shared [authProvider] so any
/// in-flight submit blocks the whole screen.
class AuthScaffold extends ConsumerWidget {
  const AuthScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider) is AuthLoading;

    final body = SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: child,
              ),
            ),
          ),
          LoadingOverlay(visible: isLoading),
        ],
      ),
    );

    if (PlatformUtils.isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text(title)),
        child: body,
      );
    }
    return Scaffold(appBar: AppBar(title: Text(title)), body: body);
  }
}
