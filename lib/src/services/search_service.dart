import '../data/bible_books.dart';
import '../models/search_result.dart';
import '../models/verse.dart';
import '../repositories/bible_repository.dart';

/// Service for searching Bible text and references.
class SearchService {
  SearchService(this._repository);

  final BibleRepository _repository;

  static final Map<String, String> _bookAliasToCanonical =
      _buildBookAliasDictionary();

  /// Supports reference, range, chapter, and fuzzy text queries.
  Future<List<SearchResult>> searchText({
    required String query,
    String? bookFilter,
    int limit = 100,
  }) async {
    final normalized = _normalizeSpaces(query).trim();
    if (normalized.isEmpty) return [];

    final referenceQuery = _parseReferenceQuery(normalized);
    if (referenceQuery != null) {
      final verses = await _searchReferenceQuery(referenceQuery);
      return verses
          .take(limit)
          .map((verse) => SearchResult(verse: verse, matchedText: verse.text))
          .toList();
    }

    return _searchByVerseText(
      query: normalized,
      bookFilter: bookFilter,
      limit: limit,
    );
  }

  /// Parse and search for a Bible reference.
  Future<List<Verse>?> searchReference(String reference) async {
    final normalized = _normalizeSpaces(reference).trim();
    if (normalized.isEmpty) return null;

    final parsed = _parseReferenceQuery(normalized);
    if (parsed == null) return null;

    final verses = await _searchReferenceQuery(parsed);
    return verses.isEmpty ? null : verses;
  }

  /// ARI format parser. Input: "bookId:chapter:verse" (e.g. "43:3:16").
  List<int>? getBibleAri(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^(\d+):(\d+):(\d+)$').firstMatch(trimmed);
    if (match == null) return null;

    final bookId = int.tryParse(match.group(1) ?? '');
    final chapter = int.tryParse(match.group(2) ?? '');
    final verse = int.tryParse(match.group(3) ?? '');

    if (bookId == null || chapter == null || verse == null) return null;
    return [bookId, chapter, verse];
  }

  /// Backward-compatible alias requested as `getBibeAri()`.
  List<int>? getBibeAri(String input) => getBibleAri(input);

  Future<List<SearchResult>> _searchByVerseText({
    required String query,
    String? bookFilter,
    required int limit,
  }) async {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) return [];

    final results = <SearchResult>[];
    final booksToSearch = bookFilter != null
        ? [bookFilter]
        : _repository.getAvailableBooks();

    for (final book in booksToSearch) {
      if (results.length >= limit) break;

      final chapterCount = _repository.getChapterCount(book);
      for (var chapter = 1; chapter <= chapterCount; chapter++) {
        if (results.length >= limit) break;

        List<Verse> verses;
        try {
          verses = await _repository.getChapter(book: book, chapter: chapter);
        } catch (_) {
          continue;
        }

        for (final verse in verses) {
          if (results.length >= limit) break;

          if (_isTextMatch(queryTokens: tokens, verseText: verse.text)) {
            results.add(
              SearchResult(
                verse: verse,
                matchedText: _extractMatchContext(verse.text, tokens),
              ),
            );
          }
        }
      }
    }

    return results;
  }

  bool _isTextMatch({
    required List<String> queryTokens,
    required String verseText,
  }) {
    final verseTokens = _tokenize(verseText);
    if (verseTokens.isEmpty) return false;

    // Direct phrase match first for exact text entries.
    final normalizedVerse = _normalizeForCompare(verseText);
    final normalizedQuery = _normalizeForCompare(queryTokens.join(' '));
    if (normalizedVerse.contains(normalizedQuery)) {
      return true;
    }

    // Order-independent exact token presence.
    final verseTokenSet = verseTokens.toSet();
    final exactAll = queryTokens.every(verseTokenSet.contains);
    if (exactAll) return true;

    // Fuzzy token presence for minor misspells or swapped words.
    for (final queryToken in queryTokens) {
      final matched = verseTokens.any(
        (verseToken) => _tokensAreSimilar(queryToken, verseToken),
      );
      if (!matched) return false;
    }

    return true;
  }

  bool _tokensAreSimilar(String a, String b) {
    if (a == b) return true;
    final distance = _levenshtein(a, b);

    if (a.length <= 4 || b.length <= 4) {
      return distance <= 1;
    }

    return distance <= 2;
  }

  int _levenshtein(String source, String target) {
    if (source == target) return 0;
    if (source.isEmpty) return target.length;
    if (target.isEmpty) return source.length;

    final rows = source.length + 1;
    final cols = target.length + 1;
    final matrix = List.generate(rows, (_) => List<int>.filled(cols, 0));

    for (var i = 0; i < rows; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j < cols; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = source[i - 1] == target[j - 1] ? 0 : 1;
        final deletion = matrix[i - 1][j] + 1;
        final insertion = matrix[i][j - 1] + 1;
        final substitution = matrix[i - 1][j - 1] + cost;

        matrix[i][j] = deletion < insertion
            ? (deletion < substitution ? deletion : substitution)
            : (insertion < substitution ? insertion : substitution);
      }
    }

    return matrix[source.length][target.length];
  }

  Future<List<Verse>> _searchReferenceQuery(_ReferenceQuery query) async {
    try {
      final chapter = await _repository.getChapter(
        book: query.book,
        chapter: query.chapter,
      );

      if (query.chapterOnly) {
        return chapter;
      }

      final start = query.startVerse ?? 1;
      final end = query.endVerse ?? start;

      return chapter
          .where(
            (verse) =>
                verse.reference.verse >= start && verse.reference.verse <= end,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  _ReferenceQuery? _parseReferenceQuery(String input) {
    final normalizedInput = _normalizeSpaces(input).toLowerCase();

    final ari = getBibleAri(normalizedInput);
    if (ari != null) {
      final bookName = _bookNameFromId(ari[0]);
      if (bookName == null) return null;
      return _ReferenceQuery(
        book: bookName,
        chapter: ari[1],
        startVerse: ari[2],
        endVerse: ari[2],
        chapterOnly: false,
      );
    }

    final raw = normalizedInput;
    final withInjectedColon = RegExp(r'^(.+?)\s+(\d+)$').hasMatch(raw)
        ? '$raw:'
        : raw;

    final match = RegExp(
      r'^(.+?)\s+(\d+)\s*(?::\s*(\d+)\s*(?:-\s*(\d+))?)?\s*:?$',
      caseSensitive: false,
    ).firstMatch(withInjectedColon);

    if (match == null) return null;

    final rawBook = _normalizeSpaces(match.group(1) ?? '').toLowerCase();
    final canonicalBook = _bookAliasToCanonical[rawBook];
    if (canonicalBook == null) return null;

    final chapter = int.tryParse(match.group(2) ?? '');
    if (chapter == null) return null;

    final startVerse = int.tryParse(match.group(3) ?? '');
    final endVerseRaw = int.tryParse(match.group(4) ?? '');
    final chapterOnly = startVerse == null;
    final endVerse = endVerseRaw ?? startVerse;

    if (!chapterOnly && endVerse != null && endVerse < startVerse) {
      return _ReferenceQuery(
        book: canonicalBook,
        chapter: chapter,
        startVerse: endVerse,
        endVerse: startVerse,
        chapterOnly: false,
      );
    }

    return _ReferenceQuery(
      book: canonicalBook,
      chapter: chapter,
      startVerse: startVerse,
      endVerse: endVerse,
      chapterOnly: chapterOnly,
    );
  }

  String _extractMatchContext(String text, List<String> queryTokens) {
    if (queryTokens.isEmpty) return text;

    final lower = text.toLowerCase();
    var bestIndex = -1;
    for (final token in queryTokens) {
      final idx = lower.indexOf(token.toLowerCase());
      if (idx >= 0 && (bestIndex == -1 || idx < bestIndex)) {
        bestIndex = idx;
      }
    }

    if (bestIndex < 0) return text;

    final start = (bestIndex - 45).clamp(0, text.length);
    final end = (bestIndex + 90).clamp(0, text.length);
    var context = text.substring(start, end);

    if (start > 0) context = '...$context';
    if (end < text.length) context = '$context...';

    return context;
  }

  List<String> _tokenize(String input) {
    return _normalizeForCompare(input)
        .split(' ')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _normalizeForCompare(String input) {
    final lower = input.toLowerCase();
    final alphaNumSpace = lower.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return _normalizeSpaces(alphaNumSpace).trim();
  }

  String _normalizeSpaces(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ');
  }

  static Map<String, String> _buildBookAliasDictionary() {
    final map = <String, String>{};

    for (final book in BibleBooks.all) {
      final canonical = book.name;
      final key = canonical.toLowerCase();
      map[key] = canonical;

      final compact = key.replaceAll(' ', '');
      map[compact] = canonical;
    }

    const aliases = <String, String>{
      'gen': 'Genesis',
      'exo': 'Exodus',
      'lev': 'Leviticus',
      'num': 'Numbers',
      'deut': 'Deuteronomy',
      'josh': 'Joshua',
      'judg': 'Judges',
      'ruth': 'Ruth',
      '1 sam': '1 Samuel',
      '2 sam': '2 Samuel',
      '1 kgs': '1 Kings',
      '2 kgs': '2 Kings',
      '1 chr': '1 Chronicles',
      '2 chr': '2 Chronicles',
      'ezra': 'Ezra',
      'neh': 'Nehemiah',
      'esth': 'Esther',
      'job': 'Job',
      'ps': 'Psalms',
      'psa': 'Psalms',
      'psalm': 'Psalms',
      'prov': 'Proverbs',
      'eccl': 'Ecclesiastes',
      'song': 'Song of Solomon',
      'isa': 'Isaiah',
      'jer': 'Jeremiah',
      'lam': 'Lamentations',
      'ezek': 'Ezekiel',
      'dan': 'Daniel',
      'hos': 'Hosea',
      'joel': 'Joel',
      'amos': 'Amos',
      'obad': 'Obadiah',
      'jonah': 'Jonah',
      'mic': 'Micah',
      'nah': 'Nahum',
      'hab': 'Habakkuk',
      'zeph': 'Zephaniah',
      'hag': 'Haggai',
      'zech': 'Zechariah',
      'mal': 'Malachi',
      'mt': 'Matthew',
      'matt': 'Matthew',
      'mk': 'Mark',
      'mrk': 'Mark',
      'lk': 'Luke',
      'jn': 'John',
      'jhn': 'John',
      'acts': 'Acts',
      'rom': 'Romans',
      '1 cor': '1 Corinthians',
      '2 cor': '2 Corinthians',
      'gal': 'Galatians',
      'eph': 'Ephesians',
      'phil': 'Philippians',
      'col': 'Colossians',
      '1 thess': '1 Thessalonians',
      '2 thess': '2 Thessalonians',
      '1 tim': '1 Timothy',
      '2 tim': '2 Timothy',
      'titus': 'Titus',
      'phlm': 'Philemon',
      'heb': 'Hebrews',
      'jas': 'James',
      '1 pet': '1 Peter',
      '2 pet': '2 Peter',
      '1 jn': '1 John',
      '2 jn': '2 John',
      '3 jn': '3 John',
      'jude': 'Jude',
      'rev': 'Revelation',
    };

    aliases.forEach((alias, canonical) {
      map[alias] = canonical;
      map[alias.replaceAll(' ', '')] = canonical;
    });

    return map;
  }

  String? _bookNameFromId(int id) {
    if (id <= 0 || id > BibleBooks.all.length) return null;
    return BibleBooks.all[id - 1].name;
  }
}

class _ReferenceQuery {
  const _ReferenceQuery({
    required this.book,
    required this.chapter,
    required this.startVerse,
    required this.endVerse,
    required this.chapterOnly,
  });

  final String book;
  final int chapter;
  final int? startVerse;
  final int? endVerse;
  final bool chapterOnly;
}
