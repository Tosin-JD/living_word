import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_plan.dart';

class ReadingPlanRepository {
  static const _activePlansKey = 'active_reading_plans_v1';
  static const _readChaptersKey = 'read_chapters_v1';
  static const _readChapterDatesKey = 'read_chapter_dates_v1';

  Future<List<ReadingPlan>> getActivePlans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activePlansKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ReadingPlan.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveActivePlans(List<ReadingPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(plans.map((plan) => plan.toJson()).toList());
    await prefs.setString(_activePlansKey, encoded);
  }

  Future<void> addPlan(ReadingPlan plan) async {
    final plans = await getActivePlans();
    plans.removeWhere((existing) => existing.id == plan.id);
    plans.add(plan);
    await saveActivePlans(plans);
  }

  Future<void> removePlan(String planId) async {
    final plans = await getActivePlans();
    plans.removeWhere((plan) => plan.id == planId);
    await saveActivePlans(plans);
  }

  Future<void> clearPlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activePlansKey);
  }

  Future<Set<String>> getReadChapterKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_readChaptersKey) ?? <String>[];
    return raw.toSet();
  }

  Future<Map<String, String>> getReadChapterDates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_readChapterDatesKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> markChapterRead({
    required String book,
    required int chapter,
  }) async {
    final key = '$book|$chapter';

    final chapterKeys = await getReadChapterKeys();
    if (chapterKeys.contains(key)) {
      return;
    }
    chapterKeys.add(key);

    final dates = await getReadChapterDates();
    dates[key] = DateTime.now().toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readChaptersKey, chapterKeys.toList());
    await prefs.setString(_readChapterDatesKey, jsonEncode(dates));
  }

  Future<void> markChapterUnread({
    required String book,
    required int chapter,
  }) async {
    final key = '$book|$chapter';

    final chapterKeys = await getReadChapterKeys();
    chapterKeys.remove(key);

    final dates = await getReadChapterDates();
    dates.remove(key);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readChaptersKey, chapterKeys.toList());
    await prefs.setString(_readChapterDatesKey, jsonEncode(dates));
  }

  Future<void> markDayRead(ReadingPlanDay day) async {
    for (final ref in day.chapterRefs) {
      await markChapterRead(book: ref.bookName, chapter: ref.chapter);
    }
  }
}
