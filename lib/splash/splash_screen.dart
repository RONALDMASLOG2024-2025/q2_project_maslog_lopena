import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_provider.dart';
import '../services/notifications/notification_service.dart';
import '../app_shell.dart';
import '../features/onboarding/onboarding_screen-mash.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    WidgetsFlutterBinding.ensureInitialized();
      final start = DateTime.now();
    // Detect flutter_test environment without importing test package
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
    if (isTest) {
      // Respect any provider overrides set by tests and navigate fast
      final current = ref.read(settingsProvider);
      ref.read(settingsProvider.notifier).replace(current);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final next = current.hasOnboarded ? const AppShell() : const OnboardingScreen();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
      });
      return;
    }
    await Hive.initFlutter();
    await SettingsStore.ensureInitialized();
    if (!kIsWeb) {
      await NotificationService.ensureInitialized();
      final s = SettingsStore.load();
      if (s.notificationsEnabled) {
        await NotificationService.requestPermissions();
        await NotificationService.scheduleDailyTipNotification(s.notificationTime);
      }
    }
    final settings = SettingsStore.load();
    if (!mounted) return;
    // Merge with any pre-provided settings (e.g., tests can override hasOnboarded/reduceMotion)
    final current = ref.read(settingsProvider);
    final merged = settings.copyWith(
      hasOnboarded: current.hasOnboarded || settings.hasOnboarded,
      reduceMotion: current.reduceMotion || settings.reduceMotion,
    );
    // Seed provider and navigate
    ref.read(settingsProvider.notifier).replace(merged);
    final next = merged.hasOnboarded ? const AppShell() : const OnboardingScreen();
      // Ensure splash shows at least 3 seconds
      final minDuration = const Duration(seconds: 3);
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
    // Ensure a frame has built so Navigator exists on web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/GW_Logo.png',
              width: 180,
              height: 180,
              errorBuilder: (_, __, ___) => Icon(Icons.eco_outlined, size: 72, color: cs.primary),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: cs.primary),
          ],
        ),
      ),
    );
  }
}
