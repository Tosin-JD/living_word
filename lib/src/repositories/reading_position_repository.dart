import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_reference.dart';

class ReadingPositionRepository {
  static const _lastReferenceKey = 'last_reading_reference_v1';
  static const _chapterOffsetsKey = 'chapter_offsets_v1';

  Future<BibleReference?> loadLastReference() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastReferenceKey);
    if (raw == null || raw.isEmpty) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return BibleReference.fromJson(json);
  }

  Future<void> saveLastReference(BibleReference reference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReferenceKey, jsonEncode(reference.toJson()));
  }

  Future<double> loadChapterOffset(String book, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chapterOffsetsKey);
    if (raw == null || raw.isEmpty) return 0.0;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    final value = map[_chapterKey(book, chapter)];
    if (value is num) return value.toDouble();
    return 0.0;
  }

  Future<void> saveChapterOffset(
    String book,
    int chapter,
    double offset,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chapterOffsetsKey);
    final map = raw == null || raw.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;

    map[_chapterKey(book, chapter)] = offset;
    await prefs.setString(_chapterOffsetsKey, jsonEncode(map));
  }

  String _chapterKey(String book, int chapter) => '$book|$chapter';
}
