import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design/design_system.dart';
import 'data/models/eco_tip.dart';
import 'features/common/widgets/eco_app_bar.dart';
import 'features/common/widgets/eco_nav_bar.dart';
import 'features/common/widgets/static_grid_bubbles_background.dart';
import 'features/progress/domain/progress_provider.dart';
import 'features/progress/domain/streak_provider.dart' show completeTodayProvider, isTodayCompletedProvider;
import 'features/progress/presentation/progress_screen.dart';
import 'features/recycling/presentation/recycling_directory_screen.dart';
import 'features/settings/domain/settings_provider.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/tips/domain/tip_provider.dart';
import 'features/tips/presentation/widgets/daily_tip_card.dart' show TipSkeleton;
import 'features/tips/presentation/widgets/daily_tip_card_modern.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final PageController _pageController = PageController(initialPage: _index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: StaticGridBubblesBackground())),
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _index = i),
            children: const [
              DailyTipScreen(),
              ProgressScreen(),
              RecyclingDirectoryScreen(),
              SettingsScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: EcoNavBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
        items: const [
          EcoNavItem(icon: Icons.lightbulb_outline, label: ''),
          EcoNavItem(icon: Icons.track_changes, label: ''),
          EcoNavItem(icon: Icons.recycling, label: ''),
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
  final Map<String, String?> _explanations = {}; // Store explanations per tip ID
  late final PageController _feedController = PageController(viewportFraction: 0.86);

  String _fallbackWhy(EcoTipCategory c, String text) {
    switch (c) {
      case EcoTipCategory.energySaving:
        return 'Lower energy use means fewer emissions from power generation. Small daily reductions add up across millions of devices.';
      case EcoTipCategory.deviceCare:
        return 'Keeping devices cool and well‑maintained extends their lifespan, delaying new manufacturing impacts.';
      case EcoTipCategory.disposal:
        return 'Proper disposal prevents toxins from entering the environment and enables material recovery.';
      case EcoTipCategory.ecoBuying:
        return 'Choosing durable, efficient products reduces resource extraction and waste over time.';
  }
  }

  @override
  Widget build(BuildContext context) {
  final feedAsync = ref.watch(tipsInfiniteFeedProvider);
  final feedCtrl = ref.read(tipsInfiniteFeedProvider.notifier);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: const EcoAppBar(title: 'GreenWise Tip'),
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: StaticGridBubblesBackground())),
          Positioned.fill(
            child: feedAsync.when(
              data: (tips) {
                if (tips.isEmpty) {
                  return const Center(child: Text('No tips available'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(dailyTipProvider);
                    ref.invalidate(tipsFeedProvider);
                    await Future.delayed(const Duration(milliseconds: 400));
                  },
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _feedController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: tips.length,
                    itemBuilder: (context, index) {
                      final t = tips[index];
                      // Prefetch more when close to the end
                      if (index >= tips.length - 2) {
                        feedCtrl.loadMore(10);
                      }
                      return AnimatedBuilder(
                        animation: _feedController,
                        builder: (context, child) {
                          double page = 0;
                          if (_feedController.hasClients &&
                              _feedController.positions.isNotEmpty) {
                            page = _feedController.page ?? 0;
                          }
                          final delta = (index - page);
                          final scale = (1 - (delta.abs() * 0.08)).clamp(0.92, 1.0);
                          final opacity = (1 - (delta.abs() * 0.35)).clamp(0.0, 1.0);
                          return RepaintBoundary(
                            child: Center(
                              child: Opacity(
                                opacity: opacity,
                                child: Transform.scale(
                                  scale: scale,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                                    child: index == 0
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              RepaintBoundary(
                                                child: DailyTipCardModern(
                                                  tip: t,
                                                  reduceMotion: settings.reduceMotion,
                                                ),
                                              ),
                                            SizedBox(height: GWDs.s4),
                                            // Check if today is completed to disable the button
                                            Consumer(
                                              builder: (context, ref, child) {
                                                final isTodayCompleted = ref.watch(isTodayCompletedProvider);
                                                return isTodayCompleted.when(
                                                  data: (isCompleted) => Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton.icon(
                                                          onPressed: isCompleted ? null : () async {
                                                            await ref
                                                                .read(completeTodayProvider.future)
                                                                .catchError((_) {});
                                                            ref.invalidate(dailyTipProvider);
                                                            // Refresh the infinite feed from today
                                                            await feedCtrl.reset();
                                                            ref.invalidate(recentCompletionsProvider);
                                                            ref.invalidate(weeklyCompletionProvider);
                                                            ref.invalidate(last30StatsProvider);
                                                            ref.invalidate(weeklyDaysProvider);
                                                          },
                                                          icon: Icon(
                                                            isCompleted ? Icons.check_circle : Icons.check_circle_rounded,
                                                            size: 20,
                                                          ),
                                                          label: Text(isCompleted ? 'Completed!' : 'Mark as done'),
                                                          style: const ButtonStyle(
                                                            elevation: WidgetStatePropertyAll(0),
                                                            padding: WidgetStatePropertyAll(
                                                              EdgeInsets.symmetric(
                                                                vertical: 14,
                                                                horizontal: 12,
                                                              ),
                                                            ),
                                                            shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: GWDs.s3),
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () {
                                                            final local = t.explanation;
                                                            setState(() {
                                                              final currentExplanation = _explanations[t.id];
                                                              _explanations[t.id] = (currentExplanation == null)
                                                                  ? ((local?.trim().isNotEmpty == true)
                                                                      ? local
                                                                      : _fallbackWhy(
                                                                          t.category, t.text))
                                                                  : null;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.info_outline_rounded,
                                                            size: 20,
                                                          ),
                                                          label: const Text('Why it matters'),
                                                          style: const ButtonStyle(
                                                            padding: WidgetStatePropertyAll(
                                                              EdgeInsets.symmetric(
                                                                vertical: 14,
                                                                horizontal: 12,
                                                              ),
                                                            ),
                                                            shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  loading: () => Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton.icon(
                                                          onPressed: null,
                                                          icon: const Icon(
                                                            Icons.check_circle_rounded,
                                                            size: 20,
                                                          ),
                                                          label: const Text('Loading...'),
                                                          style: const ButtonStyle(
                                                            elevation: WidgetStatePropertyAll(0),
                                                            padding: WidgetStatePropertyAll(
                                                              EdgeInsets.symmetric(
                                                                vertical: 14,
                                                                horizontal: 12,
                                                              ),
                                                            ),
                                                            shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: GWDs.s3),
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () {
                                                            final local = t.explanation;
                                                            setState(() {
                                                              final currentExplanation = _explanations[t.id];
                                                              _explanations[t.id] = (currentExplanation == null)
                                                                  ? ((local?.trim().isNotEmpty == true)
                                                                      ? local
                                                                      : _fallbackWhy(
                                                                          t.category, t.text))
                                                                  : null;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.info_outline_rounded,
                                                            size: 20,
                                                          ),
                                                          label: const Text('Why it matters'),
                                                          style: const ButtonStyle(
                                                            padding: WidgetStatePropertyAll(
                                                              EdgeInsets.symmetric(
                                                                vertical: 14,
                                                                horizontal: 12,
                                                              ),
                                                            ),
                                                            shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  error: (err, stack) => Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton.icon(
                                                          onPressed: () async {
                                                            await ref
                                                                .read(completeTodayProvider.future)
                                                                .catchError((_) {});
                                                            ref.invalidate(dailyTipProvider);
                                                            await feedCtrl.reset();
                                                            ref.invalidate(recentCompletionsProvider);
                                                            ref.invalidate(weeklyCompletionProvider);
                                                            ref.invalidate(last30StatsProvider);
                                                            ref.invalidate(weeklyDaysProvider);
                                                          },
                                                          icon: const Icon(
                                                            Icons.check_circle_rounded,
                                                            size: 20,
                                                          ),
                                                          label: const Text('Mark as done'),
                                                          style: const ButtonStyle(
                                                            elevation: WidgetStatePropertyAll(0),
                                                            padding: WidgetStatePropertyAll(
                                                              EdgeInsets.symmetric(
                                                                vertical: 14,
                                                                horizontal: 12,
                                                              ),
                                                            ),
                                                            shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: GWDs.s3),
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () {
                                                            final local = t.explanation;
                                                            setState(() {
                                                              final currentExplanation = _explanations[t.id];
                                                              _explanations[t.id] = (currentExplanation == null)
                                                                  ? ((local?.trim().isNotEmpty == true)
                                                                      ? local
                                                                      : _fallbackWhy(
                                                                          t.category, t.text))
                                                                  : null;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.info_outline_rounded,
                                                            size: 20,
                                                          ),
                                                          label: const Text('Why it matters'),
                                                          style: const ButtonStyle(
                                                            padding: WidgetStatePropertyAll(
                                                              EdgeInsets.symmetric(
                                                                vertical: 14,
                                                                horizontal: 12,
                                                              ),
                                                            ),
                                                            shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            if (_explanations[t.id] != null && _explanations[t.id]!.isNotEmpty) ...[
                                              SizedBox(height: GWDs.s3),
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest
                                                      .withValues(alpha: 0.9),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.12),
                                                  ),
                                                ),
                                                child: Text(
                                                  _explanations[t.id]!,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                      : RepaintBoundary(
                                          child: DailyTipCardModern(
                                            tip: t,
                                            reduceMotion: settings.reduceMotion,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const TipSkeleton(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text("Failed to load tips: $e"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
