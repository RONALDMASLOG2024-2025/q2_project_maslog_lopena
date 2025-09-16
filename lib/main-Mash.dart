// Legacy bootstrap kept for reference during refactor. Not used by the app.
// App now starts at main.dart with SplashScreen and AppShell in app_shell.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/common/widgets/eco_nav_bar.dart';
import 'features/habit/presentation/streak_provider.dart';
import 'features/onboarding/onboarding_screen-mash.dart';
import 'features/tips/application/daily_tip_provider.dart';
import 'features/tips/presentation/widgets/daily_tip_card.dart';
import 'features/tips/presentation/widgets/daily_tip_card_modern.dart';
import 'features/tips/presentation/widgets/tip_hero_stats.dart';
import 'core/design/design_system.dart';
// Explanations disabled
import 'services/notifications/notification_service.dart';
import 'settings/settings_provider.dart';
import 'settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SettingsStore.ensureInitialized();
  await NotificationService.ensureInitialized();
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
  home: settings.hasOnboarded ? const AppShell() : const OnboardingScreen(),
        supportedLocales: const [Locale('en')],
        locale: settings.locale,
      );
    });
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DailyTipScreen(),
          PlaceholderScreen(title: 'Progress (Coming Soon)'),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: EcoNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          EcoNavItem(icon: Icons.lightbulb_outline, label: ''),
          EcoNavItem(icon: Icons.track_changes, label: ''),
          EcoNavItem(icon: Icons.settings_outlined, label: ''),
        ],
      ),
    );
  }
}

class DailyTipScreen extends ConsumerStatefulWidget {
  const DailyTipScreen({super.key});

  @override
  ConsumerState<DailyTipScreen> createState() => _DailyTipScreenState();
}

class _DailyTipScreenState extends ConsumerState<DailyTipScreen> {
  // Explanations disabled; keep placeholders for structure
  String? _explanation;
  bool _loadingExplain = false;

  // Explanations disabled; no handler

  @override
  Widget build(BuildContext context) {
  final tipAsync = ref.watch(dailyTipProvider);
  final streakAsync = ref.watch(streakProvider);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('GreenWise Tip')),
      body: tipAsync.when(
        data: (tip) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dailyTipProvider);
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
            padding: EdgeInsets.only(bottom: GWDs.s8),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: GWDs.s3),
              streakAsync.when(
                data: (s) => TipHeroStats(
                  currentStreak: s.currentStreak,
                  longestStreak: s.longestStreak,
                  weeklyCompletion: 0.0, // placeholder until stats exist
                  reduceMotion: settings.reduceMotion,
                ),
                loading: () => const SizedBox(height: 170),
                error: (_, __) => const SizedBox.shrink(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                child: DailyTipCardModern(
                  tip: tip,
                  reduceMotion: settings.reduceMotion,
                ),
              ),
              // Impact placeholder section
              Padding(
                padding: EdgeInsets.fromLTRB(GWDs.s7, GWDs.s5, GWDs.s7, 0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Impact Snapshot', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Coming soon: estimated energy & CO₂ savings based on your completed tips.', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const TipSkeleton(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("Failed to load today's tip: $e"),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
