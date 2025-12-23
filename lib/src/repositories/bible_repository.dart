import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_reference.dart';
import '../models/verse.dart';

/// Repository for loading and managing Bible data from JSON assets
class BibleRepository {
  Map<String, dynamic>? _currentBibleData;
  String? _currentTranslation;

  /// Load a Bible translation from assets
  Future<void> loadTranslation(String translationFileName) async {
    // If same translation already loaded, skip
    if (_currentTranslation == translationFileName &&
        _currentBibleData != null) {
      return;
    }

    // Clean up old data to free memory
    _currentBibleData?.clear();
    _currentBibleData = null;

    // Load new translation
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/$translationFileName',
    );
    _currentBibleData = json.decode(jsonString) as Map<String, dynamic>;
    _currentTranslation = translationFileName;
  }

  /// Get all verses for a specific chapter
  Future<List<Verse>> getChapter({
    required String book,
    required int chapter,
  }) async {
    if (_currentBibleData == null) {
      throw Exception('No Bible translation loaded');
    }

    final bookData = _currentBibleData![book] as Map<String, dynamic>?;
    if (bookData == null) {
      throw Exception('Book "$book" not found');
    }

    final chapterData = bookData[chapter.toString()] as Map<String, dynamic>?;
    if (chapterData == null) {
      throw Exception('Chapter $chapter not found in book "$book"');
    }

    final List<Verse> verses = [];
    chapterData.forEach((verseNum, verseText) {
      verses.add(
        Verse(
          reference: BibleReference(
            book: book,
            chapter: chapter,
            verse: int.parse(verseNum),
          ),
          text: verseText as String,
        ),
      );
    });

    // Sort by verse number
    verses.sort((a, b) => a.reference.verse.compareTo(b.reference.verse));
    return verses;
  }

  /// Get a single verse
  Future<Verse?> getVerse({
    required String book,
    required int chapter,
    required int verse,
  }) async {
    if (_currentBibleData == null) {
      throw Exception('No Bible translation loaded');
    }

    final bookData = _currentBibleData![book] as Map<String, dynamic>?;
    if (bookData == null) return null;

    final chapterData = bookData[chapter.toString()] as Map<String, dynamic>?;
    if (chapterData == null) return null;

    final verseText = chapterData[verse.toString()] as String?;
    if (verseText == null) return null;

    return Verse(
      reference: BibleReference(book: book, chapter: chapter, verse: verse),
      text: verseText,
    );
  }

  /// Get available books in current translation
  List<String> getAvailableBooks() {
    if (_currentBibleData == null) return [];
    return _currentBibleData!.keys.toList();
  }

  /// Get number of chapters in a book
  int getChapterCount(String book) {
    if (_currentBibleData == null) return 0;
    final bookData = _currentBibleData![book] as Map<String, dynamic>?;
    if (bookData == null) return 0;
    return bookData.keys.length;
  }

  /// Get number of verses in a chapter
  int getVerseCount(String book, int chapter) {
    if (_currentBibleData == null) return 0;
    final bookData = _currentBibleData![book] as Map<String, dynamic>?;
    if (bookData == null) return 0;

    final chapterData = bookData[chapter.toString()] as Map<String, dynamic>?;
    if (chapterData == null) return 0;

    return chapterData.keys.length;
  }

  String? get currentTranslation => _currentTranslation;

  /// Clear cached data to free memory
  void dispose() {
    _currentBibleData?.clear();
    _currentBibleData = null;
    _currentTranslation = null;
  }
}
