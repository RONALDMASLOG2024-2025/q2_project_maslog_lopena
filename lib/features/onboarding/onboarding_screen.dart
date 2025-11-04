import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_shell.dart';
import '../../settings/settings_provider.dart';
import '../common/widgets/static_grid_bubbles_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _index = 0;
  bool _navigating = false;
  late AnimationController _animController;

  final _pages = const <_OnboardPageData>[
    _OnboardPageData(
      title: 'Welcome to GreenWise',
      subtitle: 'Your daily companion for sustainable electronics habits',
      description: 'Small, consistent actions that reduce e-waste and extend the life of your devices.',
      icon: Icons.eco_rounded,
      gradient: [Color(0xFF4CAF50), Color(0xFF81C784)],
    ),
    _OnboardPageData(
      title: 'Track Your Impact',
      subtitle: 'See your progress grow with every action',
      description: 'Build streaks, visualize your consistency, and measure the environmental difference you\'re making.',
      icon: Icons.trending_up_rounded,
      gradient: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    ),
    _OnboardPageData(
      title: 'Make It Personal',
      subtitle: 'Customize tips to fit your lifestyle',
      description: 'Choose categories that matter to you: device care, energy saving, recycling, or eco-buying.',
      icon: Icons.tune_rounded,
      gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_navigating) return;
    _navigating = true;
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: StaticGridBubblesBackground()),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header with Skip button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GreenWise',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: _complete,
                        child: Text(
                          'Skip',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                // PageView - with BouncingScrollPhysics to allow swipe
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(), // Enable swipe gestures
                    onPageChanged: (i) {
                      setState(() => _index = i);
                      _animController.forward(from: 0);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return RepaintBoundary(
                        child: FadeTransition(
                          opacity: _animController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animController,
                              curve: Curves.easeOutCubic,
                            )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 24), // Top padding
                                    // Gradient Icon Container
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: page.gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: page.gradient[0].withValues(alpha: 0.4),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                  // Title
                                  Text(
                                    page.title,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  // Subtitle
                                  Text(
                                    page.subtitle,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Description
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      page.description,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        height: 1.6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 24), // Bottom padding
                                ],
                              ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Page indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = _index == i;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => _index = i);
                          _controller.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                          _animController.forward(from: 0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(colors: _pages[i].gradient)
                                : null,
                            color: isActive ? null : cs.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: _pages[i].gradient[0].withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Next/Get Started button - Now outside PageView gesture area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        if (isLast) {
                          _complete();
                        } else {
                          setState(() => _index = _index + 1);
                          _controller.animateToPage(
                            _index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                          _animController.forward(from: 0);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
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
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const _OnboardPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
