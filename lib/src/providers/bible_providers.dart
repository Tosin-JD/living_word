import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/bible_reference.dart';
import '../models/verse.dart';
import '../models/search_result.dart';
import '../repositories/bible_repository.dart';
import '../repositories/reading_position_repository.dart';
import '../repositories/search_history_repository.dart';
import '../services/search_service.dart';
import '../data/bible_books.dart';

// ============================================================================
// Core Repository and Service Providers
// ============================================================================

/// Provider for the Bible repository singleton
final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});

/// Provider for the search service
final searchServiceProvider = Provider<SearchService>((ref) {
  final repository = ref.watch(bibleRepositoryProvider);
  return SearchService(repository);
});

final readingPositionRepositoryProvider = Provider<ReadingPositionRepository>((
  ref,
) {
  return ReadingPositionRepository();
});

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((
  ref,
) {
  return SearchHistoryRepository();
});

// ============================================================================
// Translation State
// ============================================================================

/// Current selected Bible translation (filename)
final currentTranslationProvider = StateProvider<String>((ref) {
  return 'HOLMAN CHRISTIAN STANDARD BIBLE.json'; // Default to HSCB
});

/// List of available translations
final availableTranslationsProvider = Provider<List<String>>((ref) {
  return [
    'HOLMAN CHRISTIAN STANDARD BIBLE.json',
    'KING JAMES BIBLE.json',
    'NEW INTERNATIONAL VERSION.json',
    'ENGLISH STANDARD VERSION.json',
    'NEW LIVING TRANSLATION.json',
    'NEW AMERICAN STANDARD BIBLE.json',
    'CHRISTIAN STANDARD BIBLE.json',
    'NEW KING JAMES VERSION.json',
    'AMPLIFIED BIBLE.json',
    'NEW REVISED STANDARD VERSION.json',
    'AMERICAN STANDARD VERSION.json',
    'BEREAN STANDARD BIBLE.json',
    'WORLD ENGLISH BIBLE.json',
    'YOUNG\'S LITERAL TRANSLATION.json',
    'LITERAL STANDARD VERSION.json',
    'LEGACY STANDARD BIBLE.json',
    'MAJORITY STANDARD BIBLE.json',
    'NASB 1995.json',
    'NASB 1977.json',
    'NET BIBLE.json',
    'NEW AMERICAN BIBLE.json',
    'NEW HEART ENGLISH BIBLE.json',
    'ENGLISH REVISED VERSION.json',
    'GOD\'S WORD® TRANSLATION.json',
    'GOOD NEWS TRANSLATION.json',
    'INTERNATIONAL STANDARD VERSION.json',
    'CONTEMPORARY ENGLISH VERSION.json',
    'DOUAY-RHEIMS BIBLE.json',
    'CATHOLIC PUBLIC DOMAIN VERSION.json',
    'LAMSA BIBLE.json',
    'WEBSTER\'S BIBLE TRANSLATION.json',
    'SMITH\'S LITERAL TRANSLATION.json',
    'BEREAN LITERAL BIBLE.json',
    'JPS TANAKH 1917.json',
    'BRENTON SEPTUAGINT TRANSLATION.json',
    'PESHITTA HOLY BIBLE TRANSLATED.json',
    'ARAMAIC BIBLE IN PLAIN ENGLISH.json',
    'WEYMOUTH NEW TESTAMENT.json',
    'ANDERSON NEW TESTAMENT.json',
    'GODBEY NEW TESTAMENT.json',
    'HAWEIS NEW TESTAMENT.json',
    'MACE NEW TESTAMENT.json',
    'WORRELL NEW TESTAMENT.json',
    'WORSLEY NEW TESTAMENT.json',
  ];
});

// ============================================================================
// Bible Reference State
// ============================================================================

/// Current Bible reference (book, chapter, verse)
final currentReferenceProvider = StateProvider<BibleReference>((ref) {
  return const BibleReference(book: 'Genesis', chapter: 1, verse: 1);
});

/// Current chapter scroll offset used to restore in-chapter position.
final currentChapterScrollOffsetProvider = StateProvider<double>((ref) => 0.0);

/// Verse target to scroll to inside the loaded chapter.
final targetVerseInChapterProvider = StateProvider<int?>((ref) => null);

// ============================================================================
// Bible Data Providers
// ============================================================================

/// Provider to load the current translation
/// This ensures the translation is loaded before accessing verses
final loadedTranslationProvider = FutureProvider<void>((ref) async {
  final translation = ref.watch(currentTranslationProvider);
  final repository = ref.watch(bibleRepositoryProvider);
  await repository.loadTranslation(translation);
});

/// Provider for the current chapter's verses
final currentChapterVersesProvider = FutureProvider<List<Verse>>((ref) async {
  // Wait for translation to load
  await ref.watch(loadedTranslationProvider.future);

  final reference = ref.watch(currentReferenceProvider);
  final repository = ref.watch(bibleRepositoryProvider);

  return repository.getChapter(
    book: reference.book,
    chapter: reference.chapter,
  );
});

/// Provider for a specific verse
final specificVerseProvider = FutureProvider.family<Verse?, BibleReference>((
  ref,
  reference,
) async {
  // Wait for translation to load
  await ref.watch(loadedTranslationProvider.future);

  final repository = ref.watch(bibleRepositoryProvider);
  return repository.getVerse(
    book: reference.book,
    chapter: reference.chapter,
    verse: reference.verse,
  );
});

// ============================================================================
// Chapter/Verse Count Providers
// ============================================================================

/// Get the number of chapters in the current book
final currentBookChapterCountProvider = Provider<int>((ref) {
  final reference = ref.watch(currentReferenceProvider);
  final book = BibleBooks.findByName(reference.book);
  return book?.chapters ?? 0;
});

/// Get the number of verses in the current chapter
final currentChapterVerseCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(loadedTranslationProvider.future);

  final reference = ref.watch(currentReferenceProvider);
  final repository = ref.watch(bibleRepositoryProvider);

  return repository.getVerseCount(reference.book, reference.chapter);
});

// ============================================================================
// Search Providers
// ============================================================================

/// Current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchHistoryController extends StateNotifier<List<String>> {
  SearchHistoryController(this._repository) : super(const []) {
    Future.microtask(_load);
  }

  final SearchHistoryRepository _repository;
  static const _maxItems = 30;

  Future<void> _load() async {
    state = await _repository.loadHistory();
  }

  Future<void> addQuery(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    final next = <String>[normalized];
    for (final item in state) {
      if (item.toLowerCase() != normalized.toLowerCase()) {
        next.add(item);
      }
    }

    if (next.length > _maxItems) {
      next.removeRange(_maxItems, next.length);
    }

    state = next;
    await _repository.saveHistory(next);
  }

  Future<void> removeQuery(String query) async {
    final next = state.where((item) => item != query).toList();
    state = next;
    await _repository.saveHistory(next);
  }

  Future<void> clearAll() async {
    state = const [];
    await _repository.saveHistory(const []);
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryController, List<String>>((ref) {
      final repository = ref.watch(searchHistoryRepositoryProvider);
      return SearchHistoryController(repository);
    });

/// Search results based on current query
final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  // Wait for translation to load
  await ref.watch(loadedTranslationProvider.future);

  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchText(query: query, limit: 50);
});

/// Search for a specific Bible reference
final referenceSearchProvider = FutureProvider.family<List<Verse>?, String>((
  ref,
  reference,
) async {
  if (reference.trim().isEmpty) return null;

  // Wait for translation to load
  await ref.watch(loadedTranslationProvider.future);

  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchReference(reference);
});
