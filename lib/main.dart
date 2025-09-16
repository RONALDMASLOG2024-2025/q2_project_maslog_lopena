import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Removed flutter_svg (hero replaced by custom hero stats)

import 'core/theme/app_theme.dart';
import 'settings/settings_provider.dart';
import 'splash/splash_screen.dart';

Future<void> main() async {
  runApp(const ProviderScope(child: GreenWiseApp()));
}

class GreenWiseApp extends StatelessWidget {
  const GreenWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final settings = ref.watch(settingsProvider);
      return MaterialApp(
        title: 'GreenWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
  home: const SplashScreen(),
        supportedLocales: const [Locale('en')],
      );
    });
  }
}

