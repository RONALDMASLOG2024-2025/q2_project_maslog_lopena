import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Removed flutter_svg (hero replaced by custom hero stats)

import 'core/theme/app_theme.dart';
import 'features/settings/domain/settings_provider.dart';
import 'features/splash/splash_screen.dart';

// Conditional import for platform-specific code
import 'initialize_database.dart' if (dart.library.html) 'initialize_database_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI overlays (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.dark, // Dark icons for light backgrounds
      statusBarBrightness: Brightness.light, // For iOS
      systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Enable edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  // Initialize database (platform-specific)
  await initializeDatabase();
  
  // DevicePreview NOTE: 
  // SQLite doesn't work well in DevicePreview on desktop.
  // For testing UI on different devices, either:
  // 1. Set enabled: false below and use responsive design tools
  // 2. Run on actual emulator/device instead
  // 3. Use web build (flutter run -d chrome)
  
  runApp(
    DevicePreview(
      // IMPORTANT: Set to false if you get database errors
      // DevicePreview + SQLite on desktop has compatibility issues
      enabled: false, // Change to false to disable DevicePreview
      builder: (context) => const ProviderScope(child: GreenWiseApp()),
    ),
  );
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
        // DevicePreview configuration
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
        supportedLocales: const [Locale('en')],
      );
    });
  }
}

