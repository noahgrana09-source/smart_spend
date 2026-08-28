import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/env/env.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SmartSpend());
}

class SmartSpend extends StatelessWidget {
  const SmartSpend({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
