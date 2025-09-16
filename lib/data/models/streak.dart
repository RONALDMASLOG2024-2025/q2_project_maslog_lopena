class StreakState {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletionDate;

  const StreakState({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletionDate,
  });

  StreakState copyWith({int? currentStreak, int? longestStreak, DateTime? lastCompletionDate}) => StreakState(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      );

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletionDate': lastCompletionDate?.toIso8601String(),
      };

  factory StreakState.fromJson(Map<String, dynamic> json) => StreakState(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastCompletionDate: json['lastCompletionDate'] != null
            ? DateTime.tryParse(json['lastCompletionDate'] as String)
            : null,
      );

  static const empty = StreakState(currentStreak: 0, longestStreak: 0, lastCompletionDate: null);
}
