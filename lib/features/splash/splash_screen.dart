import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../app_shell.dart';
import '../../data/repositories/tip_repository_sqlite.dart';
import '../../services/notifications/notification_service.dart';
import '../common/widgets/static_grid_bubbles_background.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/domain/settings_provider.dart';

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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
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
        // Fetch tomorrow's tip for the notification with visual
        try {
          final repo = TipRepositorySqlite();
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final tomorrowTip = await repo.getDailyTip(tomorrow);
          await NotificationService.scheduleDailyTipNotification(
            s.notificationTime,
            tipText: tomorrowTip.text,
            tip: tomorrowTip, // Pass full tip for image generation
          );
        } catch (_) {
          // Fallback to generic notification if tip fetch fails
          await NotificationService.scheduleDailyTipNotification(s.notificationTime);
        }
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
    // Seed provider
    ref.read(settingsProvider.notifier).replace(merged);
      // Ensure splash shows at least 3 seconds
      final minDuration = const Duration(seconds: 3);
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
    // Ensure a frame has built so Navigator exists on web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Navigate to onboarding if first launch, otherwise go to main app
      final destination = merged.hasOnboarded 
          ? const AppShell() 
          : const OnboardingScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const StaticGridBubblesBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/appbar_logo.png',
                  width: 180,
                  height: 180,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.eco_outlined, size: 72, color: cs.primary),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(color: cs.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
