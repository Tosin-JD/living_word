import '../models/search_result.dart';
import '../models/verse.dart';
import '../repositories/bible_repository.dart';

/// Service for searching Bible text
class SearchService {
  final BibleRepository _repository;

  SearchService(this._repository);

  /// Search for verses containing the query text
  Future<List<SearchResult>> searchText({
    required String query,
    String? bookFilter,
    int limit = 100,
  }) async {
    if (query.trim().isEmpty) return [];

    final searchQuery = query.toLowerCase().trim();
    final results = <SearchResult>[];

    // Get books to search
    final booksToSearch = bookFilter != null
        ? [bookFilter]
        : _repository.getAvailableBooks();

    // Search through books
    for (final book in booksToSearch) {
      if (results.length >= limit) break;

      final chapterCount = _repository.getChapterCount(book);

      for (int chapter = 1; chapter <= chapterCount; chapter++) {
        if (results.length >= limit) break;

        try {
          final verses = await _repository.getChapter(
            book: book,
            chapter: chapter,
          );

          for (final verse in verses) {
            if (results.length >= limit) break;

            if (verse.text.toLowerCase().contains(searchQuery)) {
              results.add(
                SearchResult(
                  verse: verse,
                  matchedText: _extractMatchContext(verse.text, searchQuery),
                ),
              );
            }
          }
        } catch (e) {
          // Skip chapters that don't exist
          continue;
        }
      }
    }

    return results;
  }

  /// Parse and search for a Bible reference (e.g., "John 3:16" or "Genesis 1")
  Future<List<Verse>?> searchReference(String reference) async {
    final parsed = _parseReference(reference);
    if (parsed == null) return null;

    try {
      // If verse is specified, get single verse
      if (parsed['verse'] != null) {
        final verse = await _repository.getVerse(
          book: parsed['book'] as String,
          chapter: parsed['chapter'] as int,
          verse: parsed['verse'] as int,
        );
        return verse != null ? [verse] : null;
      }

      // Otherwise get whole chapter
      return await _repository.getChapter(
        book: parsed['book'] as String,
        chapter: parsed['chapter'] as int,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse a Bible reference string
  Map<String, dynamic>? _parseReference(String reference) {
    // Simple parser for formats like:
    // - "John 3:16"
    // - "Genesis 1"
    // - "1 Corinthians 13:4-7"

    final trimmed = reference.trim();

    // Match pattern: BookName Chapter:Verse
    final regex = RegExp(
      r'^([123]?\s*[A-Za-z]+)\s+(\d+)(?::(\d+))?',
      caseSensitive: false,
    );

    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final bookName = match.group(1)?.trim();
    final chapter = int.tryParse(match.group(2) ?? '');
    final verse = match.group(3) != null ? int.tryParse(match.group(3)!) : null;

    if (bookName == null || chapter == null) return null;

    return {'book': bookName, 'chapter': chapter, 'verse': verse};
  }

  /// Extract context around the matched text
  String _extractMatchContext(
    String text,
    String query, {
    int contextLength = 50,
  }) {
    final lowerText = text.toLowerCase();
    final index = lowerText.indexOf(query);

    if (index == -1) return text;

    final start = (index - contextLength).clamp(0, text.length);
    final end = (index + query.length + contextLength).clamp(0, text.length);

    String context = text.substring(start, end);

    if (start > 0) context = '...$context';
    if (end < text.length) context = '$context...';

    return context;
  }
}
