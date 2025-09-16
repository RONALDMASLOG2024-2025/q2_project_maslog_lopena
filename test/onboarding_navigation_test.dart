import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenwise/main.dart';
import 'package:greenwise/settings/settings_provider.dart';

class _StartOnboardingNotifier extends SettingsNotifier {
  _StartOnboardingNotifier()
      : super.test(
          SettingsState.defaults().copyWith(
            hasOnboarded: false,
            reduceMotion: true,
          ),
        );
}

void main() {
  testWidgets('Onboarding Get Started/Skip navigates to home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => _StartOnboardingNotifier()),
        ],
        child: const GreenWiseApp(),
      ),
    );

    // Splash first: spinner visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 400));

    // Should land on onboarding (Skip visible)
    expect(find.text('Skip'), findsWidgets);

    // Tap Skip to finish onboarding
    await tester.tap(find.text('Skip').first);
  await tester.pump(const Duration(milliseconds: 600));

    // Now home should be visible (GreenWise Tip app bar title)
    expect(find.text('GreenWise Tip'), findsOneWidget);
  });
}
