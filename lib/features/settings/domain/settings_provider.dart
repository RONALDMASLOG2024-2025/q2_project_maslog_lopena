import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _settingsBox = 'settings_box';

class SettingsState {
  final bool darkMode;
  final Set<String> enabledCategories; // eco tip categories by enum name
  final TimeOfDay notificationTime;
  final bool notificationsEnabled;
  final Locale locale;
  final bool hasOnboarded;
  final bool reduceMotion; // accessibility: disable most animations

  const SettingsState({
    required this.darkMode,
    required this.enabledCategories,
    required this.notificationTime,
  required this.notificationsEnabled,
    required this.locale,
  required this.hasOnboarded,
  required this.reduceMotion,
  });

  SettingsState copyWith({
    bool? darkMode,
    Set<String>? enabledCategories,
    TimeOfDay? notificationTime,
  bool? notificationsEnabled,
    Locale? locale,
  bool? hasOnboarded,
  bool? reduceMotion,
  }) => SettingsState(
        darkMode: darkMode ?? this.darkMode,
        enabledCategories: enabledCategories ?? this.enabledCategories,
        notificationTime: notificationTime ?? this.notificationTime,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        locale: locale ?? this.locale,
    hasOnboarded: hasOnboarded ?? this.hasOnboarded,
    reduceMotion: reduceMotion ?? this.reduceMotion,
      );

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'enabledCategories': enabledCategories.toList(),
        'notificationHour': notificationTime.hour,
        'notificationMinute': notificationTime.minute,
  'notificationsEnabled': notificationsEnabled,
        'locale': locale.languageCode,
  'hasOnboarded': hasOnboarded,
  'reduceMotion': reduceMotion,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        darkMode: json['darkMode'] as bool? ?? false,
        enabledCategories: (json['enabledCategories'] as List?)?.cast<String>().toSet() ?? <String>{},
        notificationTime: TimeOfDay(
          hour: json['notificationHour'] as int? ?? 9,
          minute: json['notificationMinute'] as int? ?? 0,
        ),
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        locale: Locale(json['locale'] as String? ?? 'en'),
  hasOnboarded: json['hasOnboarded'] as bool? ?? true, // existing users assumed onboarded
  reduceMotion: json['reduceMotion'] as bool? ?? false,
      );

  static SettingsState defaults() => const SettingsState(
        darkMode: false,
        enabledCategories: <String>{},
        notificationTime: TimeOfDay(hour: 9, minute: 0),
  notificationsEnabled: true,
        locale: Locale('en'),
  hasOnboarded: false,
  reduceMotion: false,
      );
}

class SettingsStore {
  static late Box _box;
  static Future<void> ensureInitialized() async {
    _box = await Hive.openBox(_settingsBox);
  }

  static SettingsState load() {
    final raw = _box.get('settings') as Map?;
    if (raw == null) return SettingsState.defaults();
    return SettingsState.fromJson(Map<String, dynamic>.from(raw));
  }

  static Future<void> save(SettingsState state) async {
    await _box.put('settings', state.toJson());
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final bool _isTest;
  
  // Start with defaults to avoid touching Hive before Splash initializes it
  SettingsNotifier() : _isTest = false, super(SettingsState.defaults());

  // Private internal constructor for supplying a preset state (e.g., tests)
  SettingsNotifier._withState(super.state, this._isTest);

  // Named constructor used in tests to avoid touching Hive.
  SettingsNotifier.test(SettingsState state) : this._withState(state, true);

  // Replace state from bootstrap (splash) with a fully loaded SettingsState
  void replace(SettingsState newState) {
    state = newState;
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    if (!_isTest) await SettingsStore.save(state);
  }

  Future<void> toggleCategory(String category) async {
    final set = state.enabledCategories.contains(category)
        ? (state.enabledCategories.toSet()..remove(category))
        : (state.enabledCategories.toSet()..add(category));
    state = state.copyWith(enabledCategories: set);
    if (!_isTest) await SettingsStore.save(state);
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    state = state.copyWith(notificationTime: time);
    if (!_isTest) await SettingsStore.save(state);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    if (!_isTest) await SettingsStore.save(state);
  }

  Future<void> completeOnboarding() async {
    if (state.hasOnboarded) return;
    state = state.copyWith(hasOnboarded: true);
    if (!_isTest) await SettingsStore.save(state);
  }

  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    if (!_isTest) await SettingsStore.save(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
