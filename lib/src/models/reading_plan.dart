import '../data/bible_books.dart';

enum PlanScope { fullBible, testament, book, custom }

enum PlanType { canonical, chronological, topical, custom }

enum DifficultyLevel { easy, moderate, intense }

enum TestamentScope { oldTestament, newTestament }

enum PlanCategory {
  quickReads,
  deepStudies,
  beginner,
  intensive,
  devotional,
  chronological,
  historicalOrder,
}

class ChapterRef {
  final int bookId;
  final String bookName;
  final int chapter;

  const ChapterRef({
    required this.bookId,
    required this.bookName,
    required this.chapter,
  });

  String get key => '$bookName|$chapter';

  Map<String, dynamic> toJson() => {
    'book_id': bookId,
    'book_name': bookName,
    'chapter': chapter,
  };

  factory ChapterRef.fromJson(Map<String, dynamic> json) {
    return ChapterRef(
      bookId: json['book_id'] as int,
      bookName: json['book_name'] as String,
      chapter: json['chapter'] as int,
    );
  }
}

class ReadingPlanDay {
  final String id;
  final String readingPlanId;
  final int dayNumber;
  final int startBookId;
  final int startChapter;
  final int startVerse;
  final int endBookId;
  final int endChapter;
  final int endVerse;
  final int estimatedReadTimeMinutes;
  final List<ChapterRef> chapterRefs;

  const ReadingPlanDay({
    required this.id,
    required this.readingPlanId,
    required this.dayNumber,
    required this.startBookId,
    required this.startChapter,
    required this.startVerse,
    required this.endBookId,
    required this.endChapter,
    required this.endVerse,
    required this.estimatedReadTimeMinutes,
    required this.chapterRefs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reading_plan_id': readingPlanId,
    'day_number': dayNumber,
    'start_book_id': startBookId,
    'start_chapter': startChapter,
    'start_verse': startVerse,
    'end_book_id': endBookId,
    'end_chapter': endChapter,
    'end_verse': endVerse,
    'estimated_read_time_minutes': estimatedReadTimeMinutes,
    'chapter_refs': chapterRefs.map((ref) => ref.toJson()).toList(),
  };

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    final chapterRefsRaw = (json['chapter_refs'] as List<dynamic>? ?? []);
    return ReadingPlanDay(
      id: json['id'] as String,
      readingPlanId: json['reading_plan_id'] as String,
      dayNumber: json['day_number'] as int,
      startBookId: json['start_book_id'] as int,
      startChapter: json['start_chapter'] as int,
      startVerse: json['start_verse'] as int,
      endBookId: json['end_book_id'] as int,
      endChapter: json['end_chapter'] as int,
      endVerse: json['end_verse'] as int,
      estimatedReadTimeMinutes: json['estimated_read_time_minutes'] as int,
      chapterRefs: chapterRefsRaw
          .map((item) => ChapterRef.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final PlanScope planScope;
  final String? scopeReference;
  final PlanType planType;
  final DifficultyLevel difficultyLevel;
  final PlanCategory category;
  final bool isPremium;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReadingPlanDay> days;

  const ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.planScope,
    required this.scopeReference,
    required this.planType,
    required this.difficultyLevel,
    required this.category,
    required this.isPremium,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
  });

  int get totalChapters =>
      days.fold(0, (sum, day) => sum + day.chapterRefs.length);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'duration_days': durationDays,
    'plan_scope': planScope.name,
    'scope_reference': scopeReference,
    'plan_type': planType.name,
    'difficulty_level': difficultyLevel.name,
    'category': category.name,
    'is_premium': isPremium,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'days': days.map((day) => day.toJson()).toList(),
  };

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    final daysRaw = (json['days'] as List<dynamic>? ?? []);
    return ReadingPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      durationDays: json['duration_days'] as int,
      planScope: PlanScope.values.firstWhere(
        (value) => value.name == json['plan_scope'],
      ),
      scopeReference: json['scope_reference'] as String?,
      planType: PlanType.values.firstWhere(
        (value) => value.name == json['plan_type'],
      ),
      difficultyLevel: DifficultyLevel.values.firstWhere(
        (value) => value.name == json['difficulty_level'],
      ),
      category: PlanCategory.values.firstWhere(
        (value) =>
            value.name == (json['category'] ?? PlanCategory.devotional.name),
      ),
      isPremium: json['is_premium'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      days: daysRaw
          .map((item) => ReadingPlanDay.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  ReadingPlan copyWith({bool? isActive, DateTime? updatedAt}) {
    return ReadingPlan(
      id: id,
      name: name,
      description: description,
      durationDays: durationDays,
      planScope: planScope,
      scopeReference: scopeReference,
      planType: planType,
      difficultyLevel: difficultyLevel,
      category: category,
      isPremium: isPremium,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      days: days,
    );
  }
}

class PlanTemplate {
  final String key;
  final String name;
  final String description;
  final int durationDays;
  final PlanScope scope;
  final String? scopeReference;
  final PlanType type;
  final PlanCategory category;

  const PlanTemplate({
    required this.key,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.scope,
    required this.scopeReference,
    required this.type,
    required this.category,
  });
}

class ReadingPlanProgress {
  final int totalChapters;
  final int readChapters;
  final double percentCompleted;
  final int completedDays;
  final int remainingDays;
  final int estimatedDaysRemaining;

  const ReadingPlanProgress({
    required this.totalChapters,
    required this.readChapters,
    required this.percentCompleted,
    required this.completedDays,
    required this.remainingDays,
    required this.estimatedDaysRemaining,
  });
}

int bookIdFromName(String bookName) {
  final index = BibleBooks.all.indexWhere((book) => book.name == bookName);
  return index < 0 ? 0 : index + 1;
}

String? bookNameFromId(int bookId) {
  if (bookId <= 0 || bookId > BibleBooks.all.length) return null;
  return BibleBooks.all[bookId - 1].name;
}
