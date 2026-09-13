import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';

void main() {
  // Reproduces a bootstrap-style timing: the container is created,
  // AppState is updated during an awaited step, then runApp() builds the
  // widget tree a few event-loop turns later. Nothing listens to
  // appStateProvider in that window.
  test(
    'appStateProvider keeps its value across an async gap with no listeners',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(appStateProvider.notifier)
          .update(const AppState.authenticated());

      // The gap between restoreSession() finishing and the first frame.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(appStateProvider), const AppState.authenticated());
    },
  );
}
