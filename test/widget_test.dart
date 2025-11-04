// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenwise/features/settings/domain/settings_provider.dart';
import 'package:greenwise/main.dart';

class _FakeSettingsNotifier extends SettingsNotifier {
  _FakeSettingsNotifier()
  : super.test(SettingsState.defaults().copyWith(hasOnboarded: true, reduceMotion: true));
}

void main() {
  testWidgets('Loads daily eco-tip card', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        settingsProvider.overrideWith((ref) => _FakeSettingsNotifier()),
      ],
      child: const GreenWiseApp(),
    ));

  // initial loading spinner
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // allow futures and entrance animations to progress without waiting for indefinite animations
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump(const Duration(milliseconds: 800));

  expect(find.text('GreenWise Tip'), findsOneWidget);
  // At least one body text should be present in the card.
  expect(find.byType(Text), findsWidgets);

  // Unmount app to stop any ongoing animations before teardown
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  });
}
