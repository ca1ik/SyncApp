import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_model.dart';
import '../models/mood_log_model.dart';
import '../models/streak_model.dart';

class GamificationRepository {
  GamificationRepository({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const String _streakKey = 'sync_streak_data';
  static const String _achievementsKey = 'sync_achievements';

  Future<StreakModel> getStreak() async {
    final raw = _prefs.getString(_streakKey);
    if (raw == null) return const StreakModel();
    return StreakModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<StreakModel> recordEntry() async {
    var streak = await getStreak();
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final updatedWeekly = Map<String, int>.from(streak.weeklyEntries);
    updatedWeekly[todayKey] = (updatedWeekly[todayKey] ?? 0) + 1;

    // Clean old entries (keep 30 days)
    final cutoff = now.subtract(const Duration(days: 30));
    updatedWeekly.removeWhere((key, _) {
      final date = DateTime.tryParse(key);
      return date != null && date.isBefore(cutoff);
    });

    int newStreak = streak.currentStreak;
    if (!streak.isActiveToday) {
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      if (streak.lastEntryDate != null &&
          (updatedWeekly.containsKey(yesterdayKey) ||
              streak.lastEntryDate!.difference(now).inDays.abs() <= 1)) {
        newStreak = streak.currentStreak + 1;
      } else if (streak.lastEntryDate == null) {
        newStreak = 1;
      } else {
        newStreak = 1;
      }
    }

    streak = streak.copyWith(
      currentStreak: newStreak,
      longestStreak: max(newStreak, streak.longestStreak),
      totalEntries: streak.totalEntries + 1,
      lastEntryDate: now,
      weeklyEntries: updatedWeekly,
    );

    await _prefs.setString(_streakKey, jsonEncode(streak.toJson()));
    return streak;
  }

  Future<List<AchievementModel>> getAchievements() async {
    final raw = _prefs.getString(_achievementsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AchievementModel>> checkAndUnlockAchievements({
    required StreakModel streak,
    required List<MoodLogModel> history,
    required bool hasPartner,
    required bool hasReport,
  }) async {
    final existing = await getAchievements();
    final existingTypes = existing.map((e) => e.type).toSet();
    final newAchievements = <AchievementModel>[];
    final now = DateTime.now();

    void tryUnlock(AchievementType type) {
      if (!existingTypes.contains(type)) {
        newAchievements.add(AchievementModel(
          type: type,
          unlockedAt: now,
          isNew: true,
        ));
      }
    }

    if (streak.totalEntries >= 1) tryUnlock(AchievementType.firstMood);
    if (streak.currentStreak >= 3) tryUnlock(AchievementType.streak3);
    if (streak.currentStreak >= 7) tryUnlock(AchievementType.streak7);
    if (streak.currentStreak >= 14) tryUnlock(AchievementType.streak14);
    if (streak.currentStreak >= 30) tryUnlock(AchievementType.streak30);
    if (hasPartner) tryUnlock(AchievementType.partnerLinked);
    if (streak.totalEntries >= 10) tryUnlock(AchievementType.first10Moods);
    if (streak.totalEntries >= 50) tryUnlock(AchievementType.first50Moods);
    if (hasReport) tryUnlock(AchievementType.firstReport);

    final usedSignals = history.map((e) => e.signal).toSet();
    if (usedSignals.length >= 5) tryUnlock(AchievementType.moodVariety);

    if (history.any((m) =>
        m.timestamp != null &&
        m.timestamp!.hour >= 0 &&
        m.timestamp!.hour < 5)) {
      tryUnlock(AchievementType.nightOwl);
    }
    if (history.any((m) =>
        m.timestamp != null &&
        m.timestamp!.hour < 7 &&
        m.timestamp!.hour >= 5)) {
      tryUnlock(AchievementType.earlyBird);
    }
    if (history.any((m) =>
        m.timestamp != null &&
        (m.timestamp!.weekday == 6 || m.timestamp!.weekday == 7))) {
      tryUnlock(AchievementType.weekendWarrior);
    }

    if (newAchievements.isNotEmpty) {
      final all = [...existing, ...newAchievements];
      await _prefs.setString(
        _achievementsKey,
        jsonEncode(all.map((e) => e.toJson()).toList()),
      );
    }

    return newAchievements;
  }

  Future<int> getRelationshipScore({
    required List<MoodLogModel> history,
    required StreakModel streak,
  }) async {
    if (history.isEmpty) return 50;

    final recent = history.take(20).toList();
    double score = 50;

    // Positive signals boost score
    for (final mood in recent) {
      if (mood.signal == MoodSignal.happy) score += 3;
      if (mood.signal == MoodSignal.needTalk) score += 1;
      if (mood.signal == MoodSignal.neutral) score += 0.5;
      if (mood.signal == MoodSignal.exhausted) score -= 1;
      if (mood.signal == MoodSignal.anxious) score -= 2;
      if (mood.isSharedWithPartner) score += 1;
    }

    // Streak bonus
    score += streak.currentStreak * 0.5;

    // Average energy & tolerance
    if (recent.isNotEmpty) {
      final avgEnergy =
          recent.map((e) => e.energyLevel).reduce((a, b) => a + b) /
              recent.length;
      final avgTolerance =
          recent.map((e) => e.toleranceLevel).reduce((a, b) => a + b) /
              recent.length;
      score += (avgEnergy - 50) * 0.1;
      score += (avgTolerance - 50) * 0.1;
    }

    return score.clamp(0, 100).round();
  }
}
