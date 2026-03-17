import 'package:equatable/equatable.dart';

class StreakModel extends Equatable {
  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEntries = 0,
    this.lastEntryDate,
    this.weeklyEntries = const <String, int>{},
  });

  final int currentStreak;
  final int longestStreak;
  final int totalEntries;
  final DateTime? lastEntryDate;
  final Map<String, int> weeklyEntries;

  bool get isActiveToday {
    if (lastEntryDate == null) return false;
    final now = DateTime.now();
    return lastEntryDate!.year == now.year &&
        lastEntryDate!.month == now.month &&
        lastEntryDate!.day == now.day;
  }

  int get todayEntryCount => weeklyEntries[_todayKey] ?? 0;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalEntries,
    DateTime? lastEntryDate,
    Map<String, int>? weeklyEntries,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalEntries: totalEntries ?? this.totalEntries,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
      weeklyEntries: weeklyEntries ?? this.weeklyEntries,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalEntries': totalEntries,
        'lastEntryDate': lastEntryDate?.toIso8601String(),
        'weeklyEntries': weeklyEntries,
      };

  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        totalEntries: json['totalEntries'] as int? ?? 0,
        lastEntryDate: json['lastEntryDate'] != null
            ? DateTime.parse(json['lastEntryDate'] as String)
            : null,
        weeklyEntries: (json['weeklyEntries'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            {},
      );

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalEntries,
        lastEntryDate,
        weeklyEntries
      ];
}
