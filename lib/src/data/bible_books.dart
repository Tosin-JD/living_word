class BibleBook {
  final String name;
  final String abbreviation;
  final int chapters;
  final bool isOldTestament;

  const BibleBook({
    required this.name,
    required this.abbreviation,
    required this.chapters,
    required this.isOldTestament,
  });
}

/// All 66 books of the Bible with metadata
class BibleBooks {
  static const List<BibleBook> all = [
    // Old Testament
    BibleBook(
      name: 'Genesis',
      abbreviation: 'Gen',
      chapters: 50,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Exodus',
      abbreviation: 'Exo',
      chapters: 40,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Leviticus',
      abbreviation: 'Lev',
      chapters: 27,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Numbers',
      abbreviation: 'Num',
      chapters: 36,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Deuteronomy',
      abbreviation: 'Deu',
      chapters: 34,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Joshua',
      abbreviation: 'Jos',
      chapters: 24,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Judges',
      abbreviation: 'Jdg',
      chapters: 21,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Ruth',
      abbreviation: 'Rut',
      chapters: 4,
      isOldTestament: true,
    ),
    BibleBook(
      name: '1 Samuel',
      abbreviation: '1Sa',
      chapters: 31,
      isOldTestament: true,
    ),
    BibleBook(
      name: '2 Samuel',
      abbreviation: '2Sa',
      chapters: 24,
      isOldTestament: true,
    ),
    BibleBook(
      name: '1 Kings',
      abbreviation: '1Ki',
      chapters: 22,
      isOldTestament: true,
    ),
    BibleBook(
      name: '2 Kings',
      abbreviation: '2Ki',
      chapters: 25,
      isOldTestament: true,
    ),
    BibleBook(
      name: '1 Chronicles',
      abbreviation: '1Ch',
      chapters: 29,
      isOldTestament: true,
    ),
    BibleBook(
      name: '2 Chronicles',
      abbreviation: '2Ch',
      chapters: 36,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Ezra',
      abbreviation: 'Ezr',
      chapters: 10,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Nehemiah',
      abbreviation: 'Neh',
      chapters: 13,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Esther',
      abbreviation: 'Est',
      chapters: 10,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Job',
      abbreviation: 'Job',
      chapters: 42,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Psalms',
      abbreviation: 'Psa',
      chapters: 150,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Proverbs',
      abbreviation: 'Pro',
      chapters: 31,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Ecclesiastes',
      abbreviation: 'Ecc',
      chapters: 12,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Song of Solomon',
      abbreviation: 'Sng',
      chapters: 8,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Isaiah',
      abbreviation: 'Isa',
      chapters: 66,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Jeremiah',
      abbreviation: 'Jer',
      chapters: 52,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Lamentations',
      abbreviation: 'Lam',
      chapters: 5,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Ezekiel',
      abbreviation: 'Eze',
      chapters: 48,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Daniel',
      abbreviation: 'Dan',
      chapters: 12,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Hosea',
      abbreviation: 'Hos',
      chapters: 14,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Joel',
      abbreviation: 'Joe',
      chapters: 3,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Amos',
      abbreviation: 'Amo',
      chapters: 9,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Obadiah',
      abbreviation: 'Oba',
      chapters: 1,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Jonah',
      abbreviation: 'Jon',
      chapters: 4,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Micah',
      abbreviation: 'Mic',
      chapters: 7,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Nahum',
      abbreviation: 'Nah',
      chapters: 3,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Habakkuk',
      abbreviation: 'Hab',
      chapters: 3,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Zephaniah',
      abbreviation: 'Zep',
      chapters: 3,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Haggai',
      abbreviation: 'Hag',
      chapters: 2,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Zechariah',
      abbreviation: 'Zec',
      chapters: 14,
      isOldTestament: true,
    ),
    BibleBook(
      name: 'Malachi',
      abbreviation: 'Mal',
      chapters: 4,
      isOldTestament: true,
    ),

    // New Testament
    BibleBook(
      name: 'Matthew',
      abbreviation: 'Mat',
      chapters: 28,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Mark',
      abbreviation: 'Mrk',
      chapters: 16,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Luke',
      abbreviation: 'Luk',
      chapters: 24,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'John',
      abbreviation: 'Jhn',
      chapters: 21,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Acts',
      abbreviation: 'Act',
      chapters: 28,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Romans',
      abbreviation: 'Rom',
      chapters: 16,
      isOldTestament: false,
    ),
    BibleBook(
      name: '1 Corinthians',
      abbreviation: '1Co',
      chapters: 16,
      isOldTestament: false,
    ),
    BibleBook(
      name: '2 Corinthians',
      abbreviation: '2Co',
      chapters: 13,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Galatians',
      abbreviation: 'Gal',
      chapters: 6,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Ephesians',
      abbreviation: 'Eph',
      chapters: 6,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Philippians',
      abbreviation: 'Php',
      chapters: 4,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Colossians',
      abbreviation: 'Col',
      chapters: 4,
      isOldTestament: false,
    ),
    BibleBook(
      name: '1 Thessalonians',
      abbreviation: '1Th',
      chapters: 5,
      isOldTestament: false,
    ),
    BibleBook(
      name: '2 Thessalonians',
      abbreviation: '2Th',
      chapters: 3,
      isOldTestament: false,
    ),
    BibleBook(
      name: '1 Timothy',
      abbreviation: '1Ti',
      chapters: 6,
      isOldTestament: false,
    ),
    BibleBook(
      name: '2 Timothy',
      abbreviation: '2Ti',
      chapters: 4,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Titus',
      abbreviation: 'Tit',
      chapters: 3,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Philemon',
      abbreviation: 'Phm',
      chapters: 1,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Hebrews',
      abbreviation: 'Heb',
      chapters: 13,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'James',
      abbreviation: 'Jas',
      chapters: 5,
      isOldTestament: false,
    ),
    BibleBook(
      name: '1 Peter',
      abbreviation: '1Pe',
      chapters: 5,
      isOldTestament: false,
    ),
    BibleBook(
      name: '2 Peter',
      abbreviation: '2Pe',
      chapters: 3,
      isOldTestament: false,
    ),
    BibleBook(
      name: '1 John',
      abbreviation: '1Jn',
      chapters: 5,
      isOldTestament: false,
    ),
    BibleBook(
      name: '2 John',
      abbreviation: '2Jn',
      chapters: 1,
      isOldTestament: false,
    ),
    BibleBook(
      name: '3 John',
      abbreviation: '3Jn',
      chapters: 1,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Jude',
      abbreviation: 'Jud',
      chapters: 1,
      isOldTestament: false,
    ),
    BibleBook(
      name: 'Revelation',
      abbreviation: 'Rev',
      chapters: 22,
      isOldTestament: false,
    ),
  ];

  static BibleBook? findByName(String name) {
    try {
      return all.firstWhere(
        (book) => book.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<BibleBook> get oldTestament =>
      all.where((book) => book.isOldTestament).toList();

  static List<BibleBook> get newTestament =>
      all.where((book) => !book.isOldTestament).toList();
}
