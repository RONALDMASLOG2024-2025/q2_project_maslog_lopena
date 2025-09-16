import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenwise/settings/settings_provider.dart';
import 'package:greenwise/app_shell.dart';
import 'widgets/web_wires_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _navigating = false;

  final _pages = <_OnboardPageData>[
    _OnboardPageData(
      title: 'Welcome to GreenWise',
      subtitle: 'Small daily actions for sustainable electronics use.',
      bullets: [
        'One eco-tip a day',
        'Clear, friendly guidance',
        'Built for consistency',
      ],
      icon: Icons.eco_outlined,
    ),
    _OnboardPageData(
      title: 'Why It Exists',
      subtitle: 'E‑waste grows fast. Most people lack simple, guided habits.',
      bullets: [
        'Reduce device waste',
        'Extend gadget life',
        'Lower energy usage',
      ],
      icon: Icons.warning_amber_rounded,
    ),
    _OnboardPageData(
      title: 'How It Works',
      subtitle: 'Swipe in daily, complete a tip, learn the “why”.',
      bullets: [
        'Short “why it matters”',
        'Track streak progress',
        'Pick categories you like',
      ],
      icon: Icons.lightbulb_outline,
    ),
    _OnboardPageData(
      title: 'Build The Habit',
      subtitle: 'Micro‑wins + streaks = long‑term sustainable behavior.',
      bullets: [
        'Positive reinforcement',
        'Low cognitive load',
        'Meaningful progress',
      ],
      icon: Icons.auto_awesome,
    ),
    _OnboardPageData(
      title: 'Ready?',
      subtitle: 'Let’s start your first eco habit today.',
      bullets: [
        'You can adjust later',
        'Stay curious & consistent',
        'Small actions. Lasting impact.',
      ],
      icon: Icons.rocket_launch_outlined,
    ),
  ];

  Future<void> _finish() async {
    if (_navigating) return;
    _navigating = true;
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (!mounted) return;
    // Navigate to the main app shell
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _index == _pages.length - 1;
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!reduceMotion)
            const Positioned.fill(
              child: IgnorePointer(
                child: WebWiresBackground(
                  nodeCount: 28,
                  neighborCount: 2,
                  opacity: 0.08,
                  lineWidthMin: 0.7,
                  lineWidthMax: 1.3,
                  nodeMin: 1.6,
                  nodeMax: 2.6,
                  driftUpPerSecond: 0.008,
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
              // Skip button row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text('GreenWise', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                    const Spacer(),
                    if (!isLast)
                      TextButton(
                        onPressed: _finish,
                        child: const Text('Skip'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) => _OnboardPage(view: _pages[i]),
                ),
              ),
              // Indicators
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (i == _index) return;
                          _controller.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 340),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: Semantics(
                          label: 'Go to onboarding slide ${i + 1}',
                          selected: _index == i,
                          button: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              height: 10,
                              width: _index == i ? 30 : 12,
                              decoration: BoxDecoration(
                                color: _index == i
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: _index == i
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          backgroundColor: isLast ? theme.colorScheme.primary : theme.colorScheme.primaryContainer,
                          foregroundColor: isLast ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimaryContainer,
                        ),
                        onPressed: _next,
                        child: Text(isLast ? 'Get Started' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPageData {
  final String title;
  final String subtitle;
  final List<String> bullets;
  final IconData icon;
  const _OnboardPageData({required this.title, required this.subtitle, required this.bullets, required this.icon});
}

class _OnboardPage extends StatelessWidget {
  final _OnboardPageData view;
  const _OnboardPage({required this.view});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withValues(alpha: .85), theme.colorScheme.primary.withValues(alpha: .55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: theme.colorScheme.primary.withValues(alpha: .35), blurRadius: 28, spreadRadius: 2, offset: const Offset(0, 8)),
              ],
            ),
            padding: const EdgeInsets.all(26),
            child: Icon(view.icon, size: 56, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 36),
          Text(
            view.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 10),
          Text(view.subtitle, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.35)),
          const SizedBox(height: 28),
          ...view.bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      height: 9,
                      width: 9,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        b,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                      ),
                    ),
                  ],
                ),
              )),
          const Spacer(),
        ],
      ),
    );
  }
}
