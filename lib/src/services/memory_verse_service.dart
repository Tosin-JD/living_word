import '../models/app_settings.dart';
import '../models/bible_reference.dart';
import '../repositories/bible_repository.dart';

class MemoryVerseItem {
  final String referenceLabel;
  final String text;

  const MemoryVerseItem({required this.referenceLabel, required this.text});

  String toNotificationBody() {
    return '$referenceLabel - $text';
  }
}

class MemoryVerseService {
  MemoryVerseService(this._repository);

  final BibleRepository _repository;

  static const List<String> encouragingReferences = [
    'Philippians 4:13',
    'Isaiah 41:10',
    'Jeremiah 29:11',
    'Romans 8:28',
    'Psalm 23:1',
    'Proverbs 3:5',
    'Matthew 11:28',
    '2 Timothy 1:7',
    'Joshua 1:9',
    'Psalm 46:1',
    'Romans 12:12',
    'Hebrews 11:1',
    'John 14:27',
    'Psalm 119:105',
    'Lamentations 3:22',
    'Psalm 27:1',
    'Colossians 3:23',
    'Galatians 6:9',
    'James 1:5',
    'Psalm 34:8',
    '1 Thessalonians 5:16',
    'Ephesians 3:20',
    'Romans 15:13',
    'Psalm 121:1',
    'John 16:33',
    '1 Peter 5:7',
    'Micah 6:8',
    'Psalm 37:4',
    'Deuteronomy 31:8',
    '2 Corinthians 5:7',
  ];

  Future<MemoryVerseItem?> getVerseForMoment({
    required DateTime moment,
    required int slotIndex,
    required AppSettings settings,
  }) async {
    final references = _resolveReferences(settings);
    if (references.isEmpty) return null;

    final index = _resolveIndex(
      moment: moment,
      slotIndex: slotIndex,
      length: references.length,
      mode: settings.memoryVerseMode,
    );

    final refString = references[index];
    final reference = _parseReference(refString);
    if (reference == null) {
      return MemoryVerseItem(
        referenceLabel: refString,
        text: 'Open app to read this memory verse.',
      );
    }

    await _repository.loadTranslation(settings.defaultTranslation);
    final verse = await _repository.getVerse(
      book: reference.book,
      chapter: reference.chapter,
      verse: reference.verse,
    );

    if (verse == null) {
      return MemoryVerseItem(
        referenceLabel: refString,
        text: 'Open app to read this memory verse.',
      );
    }

    final label =
        '${verse.reference.book} ${verse.reference.chapter}:${verse.reference.verse}';
    return MemoryVerseItem(referenceLabel: label, text: verse.text);
  }

  List<String> _resolveReferences(AppSettings settings) {
    final curated = settings.curatedMemoryVerseReferences
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (settings.memoryVerseMode == MemoryVerseMode.curated &&
        curated.isNotEmpty) {
      return curated;
    }

    return encouragingReferences;
  }

  int _resolveIndex({
    required DateTime moment,
    required int slotIndex,
    required int length,
    required MemoryVerseMode mode,
  }) {
    final daySerial = DateTime(
      moment.year,
      moment.month,
      moment.day,
    ).difference(DateTime(2024, 1, 1)).inDays;
    final slotSerial = (daySerial * 100) + slotIndex;

    if (mode == MemoryVerseMode.encouragementSequential ||
        mode == MemoryVerseMode.curated) {
      return slotSerial % length;
    }

    return ((slotSerial * 37) + 11) % length;
  }

  BibleReference? _parseReference(String input) {
    final match = RegExp(r'^(.+?)\s+(\d+):(\d+)$').firstMatch(input.trim());
    if (match == null) return null;

    final book = match.group(1)?.trim();
    final chapter = int.tryParse(match.group(2) ?? '');
    final verse = int.tryParse(match.group(3) ?? '');

    if (book == null || chapter == null || verse == null) return null;

    return BibleReference(book: book, chapter: chapter, verse: verse);
  }
}
