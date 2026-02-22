import '../data/bible_books.dart';
import '../models/reading_plan.dart';

class ReadingPlanService {
  List<PlanTemplate> getSystemTemplates() {
    return const [
      PlanTemplate(
        key: 'full_120_canonical',
        name: 'Full Bible in 120 Days',
        description: 'Read through the entire Bible in 120 days.',
        durationDays: 120,
        scope: PlanScope.fullBible,
        scopeReference: null,
        type: PlanType.canonical,
        category: PlanCategory.intensive,
      ),
      PlanTemplate(
        key: 'full_150_canonical',
        name: 'Full Bible in 150 Days',
        description: 'Read through the entire Bible in 150 days.',
        durationDays: 150,
        scope: PlanScope.fullBible,
        scopeReference: null,
        type: PlanType.canonical,
        category: PlanCategory.deepStudies,
      ),
      PlanTemplate(
        key: 'full_365_canonical',
        name: 'Full Bible in 365 Days',
        description: 'Read through the entire Bible in one year.',
        durationDays: 365,
        scope: PlanScope.fullBible,
        scopeReference: null,
        type: PlanType.canonical,
        category: PlanCategory.beginner,
      ),
      PlanTemplate(
        key: 'nt_90',
        name: 'New Testament in 90 Days',
        description: 'A focused New Testament journey.',
        durationDays: 90,
        scope: PlanScope.testament,
        scopeReference: 'NT',
        type: PlanType.canonical,
        category: PlanCategory.quickReads,
      ),
      PlanTemplate(
        key: 'ot_180',
        name: 'Old Testament in 180 Days',
        description: 'A guided Old Testament plan.',
        durationDays: 180,
        scope: PlanScope.testament,
        scopeReference: 'OT',
        type: PlanType.canonical,
        category: PlanCategory.deepStudies,
      ),
    ];
  }

  ReadingPlan buildFromTemplate(PlanTemplate template) {
    return buildFromTemplateWithStart(template);
  }

  ReadingPlan buildFromTemplateWithStart(
    PlanTemplate template, {
    String? startBookName,
  }) {
    switch (template.scope) {
      case PlanScope.fullBible:
        return createFullBiblePlan(
          durationDays: template.durationDays,
          name: template.name,
          description: template.description,
          planType: template.type,
          category: template.category,
          startBookName: startBookName,
        );
      case PlanScope.testament:
        final testament = template.scopeReference == 'OT'
            ? TestamentScope.oldTestament
            : TestamentScope.newTestament;
        return createTestamentPlan(
          testament: testament,
          durationDays: template.durationDays,
          name: template.name,
          description: template.description,
          planType: template.type,
          category: template.category,
          startBookName: startBookName,
        );
      case PlanScope.book:
      case PlanScope.custom:
        throw ArgumentError('Template scope not supported for direct build.');
    }
  }

  ReadingPlan createFullBiblePlan({
    required int durationDays,
    required String name,
    required String description,
    PlanType planType = PlanType.canonical,
    PlanCategory category = PlanCategory.deepStudies,
    String? startBookName,
  }) {
    final books = _rotateBooks(BibleBooks.all, startBookName);
    return _createPlan(
      name: name,
      description: description,
      scope: PlanScope.fullBible,
      scopeReference: null,
      planType: planType,
      category: category,
      books: books,
      durationDays: durationDays,
    );
  }

  ReadingPlan createTestamentPlan({
    required TestamentScope testament,
    required int durationDays,
    required String name,
    required String description,
    PlanType planType = PlanType.canonical,
    PlanCategory category = PlanCategory.deepStudies,
    String? startBookName,
  }) {
    final baseBooks = testament == TestamentScope.oldTestament
        ? BibleBooks.oldTestament
        : BibleBooks.newTestament;
    final books = _rotateBooks(baseBooks, startBookName);

    return _createPlan(
      name: name,
      description: description,
      scope: PlanScope.testament,
      scopeReference: testament == TestamentScope.oldTestament ? 'OT' : 'NT',
      planType: planType,
      category: category,
      books: books,
      durationDays: durationDays,
    );
  }

  ReadingPlan createBookPlan({
    required List<String> bookNames,
    required int durationDays,
    String? customName,
    String? customDescription,
    PlanType planType = PlanType.canonical,
    PlanCategory category = PlanCategory.quickReads,
    String? startBookName,
  }) {
    var books = <BibleBook>[];
    for (final name in bookNames) {
      final book = BibleBooks.findByName(name);
      if (book != null) books.add(book);
    }
    books = _rotateBooks(books, startBookName);

    if (books.isEmpty) {
      throw ArgumentError('No valid books selected for plan generation.');
    }

    final defaultName = books.length == 1
        ? '${books.first.name} in $durationDays Days'
        : '${books.map((book) => book.name).join(', ')} in $durationDays Days';

    return _createPlan(
      name: customName ?? defaultName,
      description: customDescription ?? 'Generated book plan.',
      scope: PlanScope.book,
      scopeReference: bookNames.join(','),
      planType: planType,
      category: category,
      books: books,
      durationDays: durationDays,
    );
  }

  ReadingPlan recalculatePlanPace({
    required ReadingPlan plan,
    required Set<String> readChapterKeys,
    required int remainingDays,
  }) {
    if (remainingDays < 1) {
      throw ArgumentError('remainingDays must be at least 1.');
    }

    final remainingRefs = plan.days
        .expand((day) => day.chapterRefs)
        .where((ref) => !readChapterKeys.contains(ref.key))
        .toList();

    return _createPlanFromRefs(
      name: '${plan.name} (Catch-up)',
      description: 'Recalculated pace for remaining chapters.',
      scope: plan.planScope,
      scopeReference: plan.scopeReference,
      planType: plan.planType,
      category: plan.category,
      refs: remainingRefs,
      durationDays: remainingDays,
      isPremium: plan.isPremium,
    );
  }

  ReadingPlanProgress calculateProgress({
    required ReadingPlan plan,
    required Set<String> readChapterKeys,
  }) {
    final total = plan.totalChapters;
    final read = plan.days
        .expand((day) => day.chapterRefs)
        .where((ref) => readChapterKeys.contains(ref.key))
        .length;

    final completedDays = plan.days
        .where(
          (day) =>
              day.chapterRefs.isNotEmpty &&
              day.chapterRefs.every((ref) => readChapterKeys.contains(ref.key)),
        )
        .length;

    final remainingDays = (plan.durationDays - completedDays).clamp(
      0,
      plan.durationDays,
    );

    final percent = total == 0 ? 0.0 : (read / total) * 100;

    final chaptersPerDay = total == 0 ? 1 : (total / plan.durationDays);
    final remainingChapters = (total - read).clamp(0, total);
    final estimatedDaysRemaining = chaptersPerDay <= 0
        ? 0
        : (remainingChapters / chaptersPerDay).ceil();

    return ReadingPlanProgress(
      totalChapters: total,
      readChapters: read,
      percentCompleted: percent,
      completedDays: completedDays,
      remainingDays: remainingDays,
      estimatedDaysRemaining: estimatedDaysRemaining,
    );
  }

  int calculateStreak(Map<String, String> readChapterDates) {
    if (readChapterDates.isEmpty) return 0;

    final dateOnly =
        readChapterDates.values
            .map(DateTime.parse)
            .map((dt) => DateTime(dt.year, dt.month, dt.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    var current = DateTime(today.year, today.month, today.day);

    var streak = 0;
    for (final day in dateOnly) {
      if (day == current) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else if (day.isBefore(current)) {
        break;
      }
    }

    return streak;
  }

  List<String> getRecommendedPlanKeys({required Set<String> readChapterKeys}) {
    if (readChapterKeys.isEmpty) {
      return ['john_7', 'nt_90'];
    }

    final psalmsReadCount = readChapterKeys
        .where((key) => key.startsWith('Psalms|'))
        .length;

    if (psalmsReadCount >= 10) {
      return ['psalms_30', 'nt_90'];
    }

    return ['full_150_canonical', 'nt_90'];
  }

  ReadingPlan createRecommendedPlanFromKey(String key) {
    switch (key) {
      case 'john_7':
        return createBookPlan(
          bookNames: const ['John'],
          durationDays: 7,
          customDescription: 'A fast and focused start through John.',
          category: PlanCategory.beginner,
        );
      case 'psalms_30':
        return createBookPlan(
          bookNames: const ['Psalms'],
          durationDays: 30,
          customDescription: 'Read Psalms in 30 days.',
          category: PlanCategory.devotional,
        );
      case 'nt_90':
        return createTestamentPlan(
          testament: TestamentScope.newTestament,
          durationDays: 90,
          name: 'New Testament in 90 Days',
          description: 'A focused New Testament journey.',
        );
      default:
        final template = getSystemTemplates().firstWhere(
          (item) => item.key == key,
          orElse: () => getSystemTemplates().first,
        );
        return buildFromTemplate(template);
    }
  }

  ChapterRef? resolveNextChapterForPlan({
    required ReadingPlan plan,
    required Set<String> readChapterKeys,
    Map<String, String>? readChapterDates,
    String? preferredBookName,
  }) {
    final refs = plan.days.expand((day) => day.chapterRefs).toList();
    if (refs.isEmpty) return null;

    final unreadRefs = refs
        .where((ref) => !readChapterKeys.contains(ref.key))
        .toList();
    if (unreadRefs.isEmpty) {
      return refs.last;
    }

    String? focusBook = preferredBookName;
    if (focusBook == null || !refs.any((ref) => ref.bookName == focusBook)) {
      focusBook = _resolveLatestReadBookInPlan(
        refs: refs,
        readChapterDates: readChapterDates,
      );
    }

    if (focusBook != null) {
      final unreadInFocusBook = unreadRefs
          .where((ref) => ref.bookName == focusBook)
          .toList();
      if (unreadInFocusBook.isNotEmpty) {
        return unreadInFocusBook.first;
      }

      final bookOrder = _bookOrder(refs);
      final currentIndex = bookOrder.indexOf(focusBook);
      if (currentIndex >= 0) {
        for (var i = currentIndex + 1; i < bookOrder.length; i++) {
          final nextBookUnread = unreadRefs
              .where((ref) => ref.bookName == bookOrder[i])
              .toList();
          if (nextBookUnread.isNotEmpty) return nextBookUnread.first;
        }
        for (var i = 0; i < currentIndex; i++) {
          final nextBookUnread = unreadRefs
              .where((ref) => ref.bookName == bookOrder[i])
              .toList();
          if (nextBookUnread.isNotEmpty) return nextBookUnread.first;
        }
      }
    }

    return unreadRefs.first;
  }

  ReadingPlan _createPlan({
    required String name,
    required String description,
    required PlanScope scope,
    required String? scopeReference,
    required PlanType planType,
    required PlanCategory category,
    required List<BibleBook> books,
    required int durationDays,
  }) {
    final refs = _chapterRefsFromBooks(books);

    return _createPlanFromRefs(
      name: name,
      description: description,
      scope: scope,
      scopeReference: scopeReference,
      planType: planType,
      category: category,
      refs: refs,
      durationDays: durationDays,
      isPremium: false,
    );
  }

  ReadingPlan _createPlanFromRefs({
    required String name,
    required String description,
    required PlanScope scope,
    required String? scopeReference,
    required PlanType planType,
    required PlanCategory category,
    required List<ChapterRef> refs,
    required int durationDays,
    required bool isPremium,
  }) {
    if (durationDays < 1) {
      throw ArgumentError('durationDays must be at least 1.');
    }

    final now = DateTime.now();
    final planId = 'plan_${now.microsecondsSinceEpoch}';

    final baseChapters = refs.length ~/ durationDays;
    var extra = refs.length % durationDays;

    final days = <ReadingPlanDay>[];
    var cursor = 0;

    for (var dayNumber = 1; dayNumber <= durationDays; dayNumber++) {
      var chaptersForDay = baseChapters;
      if (extra > 0) {
        chaptersForDay++;
        extra--;
      }

      final dayRefs = refs.skip(cursor).take(chaptersForDay).toList();
      cursor += chaptersForDay;

      if (dayRefs.isEmpty) {
        continue;
      }

      final startRef = dayRefs.first;
      final endRef = dayRefs.last;

      days.add(
        ReadingPlanDay(
          id: 'day_${planId}_$dayNumber',
          readingPlanId: planId,
          dayNumber: dayNumber,
          startBookId: startRef.bookId,
          startChapter: startRef.chapter,
          startVerse: 1,
          endBookId: endRef.bookId,
          endChapter: endRef.chapter,
          endVerse: 999,
          estimatedReadTimeMinutes: (dayRefs.length * 3).clamp(3, 90),
          chapterRefs: dayRefs,
        ),
      );
    }

    final chaptersPerDay = refs.isEmpty ? 0 : refs.length / durationDays;
    final difficulty = chaptersPerDay <= 3
        ? DifficultyLevel.easy
        : chaptersPerDay <= 6
        ? DifficultyLevel.moderate
        : DifficultyLevel.intense;

    return ReadingPlan(
      id: planId,
      name: name,
      description: description,
      durationDays: durationDays,
      planScope: scope,
      scopeReference: scopeReference,
      planType: planType,
      difficultyLevel: difficulty,
      category: category,
      isPremium: isPremium,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      days: days,
    );
  }

  List<ChapterRef> _chapterRefsFromBooks(List<BibleBook> books) {
    final refs = <ChapterRef>[];

    for (final book in books) {
      final bookId = bookIdFromName(book.name);
      for (var chapter = 1; chapter <= book.chapters; chapter++) {
        refs.add(
          ChapterRef(bookId: bookId, bookName: book.name, chapter: chapter),
        );
      }
    }

    return refs;
  }

  List<BibleBook> _rotateBooks(List<BibleBook> books, String? startBookName) {
    if (startBookName == null || startBookName.isEmpty) return books;

    final index = books.indexWhere((book) => book.name == startBookName);
    if (index <= 0) return books;

    return [...books.sublist(index), ...books.sublist(0, index)];
  }

  String? _resolveLatestReadBookInPlan({
    required List<ChapterRef> refs,
    Map<String, String>? readChapterDates,
  }) {
    if (readChapterDates == null || readChapterDates.isEmpty) return null;

    final planKeys = refs.map((ref) => ref.key).toSet();
    final candidates = readChapterDates.entries
        .where((entry) => planKeys.contains(entry.key))
        .toList();

    if (candidates.isEmpty) return null;

    candidates.sort(
      (a, b) => DateTime.parse(b.value).compareTo(DateTime.parse(a.value)),
    );
    return candidates.first.key.split('|').first;
  }

  List<String> _bookOrder(List<ChapterRef> refs) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final ref in refs) {
      if (seen.add(ref.bookName)) {
        ordered.add(ref.bookName);
      }
    }
    return ordered;
  }
}
