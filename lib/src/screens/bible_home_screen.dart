import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../models/bible_reference.dart';
import '../data/bible_books.dart';
import '../providers/bible_providers.dart';
import '../providers/reading_plan_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/verse_list_widget.dart';
import '../widgets/navigation_controls.dart';
import '../widgets/bible_search_bar.dart';
import '../widgets/bible_selector_dialog.dart';
import '../widgets/translation_selector_dialog.dart';
import '../utils/navigation_utils.dart';
import 'reading_insights_screen.dart';
import 'notifications_screen.dart';
import 'reading_plan_screen.dart';
import 'settings_screen.dart';

class BibleHomeScreen extends ConsumerStatefulWidget {
  const BibleHomeScreen({super.key});

  @override
  ConsumerState<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

class _BibleHomeScreenState extends ConsumerState<BibleHomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<BibleSearchBarState> _searchBarKey =
      GlobalKey<BibleSearchBarState>();
  bool _showSearchBar = false;
  bool _hydratedReadingPosition = false;
  bool _showModeToggleButton = true;
  Timer? _modeButtonHideTimer;
  late final AnimationController _swipeAnimationController;
  double _horizontalDragOffset = 0;
  double _dragViewportWidth = 1;
  bool _swipeAnimating = false;
  bool _hasObservedChapterScroll = false;
  double _lastObservedChapterOffset = 0;
  int _upwardReadSwipes = 0;
  DateTime? _lastUpwardReadSwipeAt;
  String? _bottomMarkedChapterKey;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(vsync: this);
    Future.microtask(_hydrateReadingPosition);
  }

  @override
  void dispose() {
    _modeButtonHideTimer?.cancel();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _animateDragOffsetTo(
    double target, {
    Duration duration = const Duration(milliseconds: 220),
    Curve curve = Curves.easeOutCubic,
  }) async {
    if (!mounted) return;
    final begin = _horizontalDragOffset;
    if ((begin - target).abs() < 0.5) {
      setState(() => _horizontalDragOffset = target);
      return;
    }

    _swipeAnimationController
      ..stop()
      ..duration = duration
      ..reset();

    final animation = Tween<double>(
      begin: begin,
      end: target,
    ).animate(CurvedAnimation(parent: _swipeAnimationController, curve: curve));

    void listener() {
      if (!mounted) return;
      setState(() => _horizontalDragOffset = animation.value);
    }

    _swipeAnimationController.addListener(listener);
    try {
      await _swipeAnimationController.forward();
    } finally {
      _swipeAnimationController.removeListener(listener);
    }
  }

  Future<void> _completeSwipeNavigation({required bool goNext}) async {
    if (_swipeAnimating || !mounted) return;
    _swipeAnimating = true;

    final width = _dragViewportWidth <= 1 ? 1.0 : _dragViewportWidth;
    final outTarget = goNext ? -width : width;
    await _animateDragOffsetTo(
      outTarget,
      duration: const Duration(milliseconds: 160),
    );

    final reference = ref.read(currentReferenceProvider);
    if (goNext) {
      _goToNextChapterAcrossBooks(reference);
    } else {
      _goToPreviousChapterAcrossBooks(reference);
    }

    // Start the new chapter slightly offscreen so it feels like linked pages.
    if (mounted) {
      setState(
        () => _horizontalDragOffset = goNext ? width * 0.18 : -width * 0.18,
      );
      await _animateDragOffsetTo(
        0,
        duration: const Duration(milliseconds: 220),
      );
    }

    _swipeAnimating = false;
  }

  void _handleHorizontalDragUpdate(
    DragUpdateDetails details,
    AppSettings settings,
  ) {
    if (_swipeAnimating) return;
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) return;

    final maxDrag = _dragViewportWidth * 0.92;
    setState(() {
      _horizontalDragOffset = (_horizontalDragOffset + delta).clamp(
        -maxDrag,
        maxDrag,
      );
    });

    if (settings.readingMode) {
      _handleModeButtonVisibility(readingMode: true);
    }
  }

  Future<void> _handleHorizontalDragEnd(DragEndDetails details) async {
    if (_swipeAnimating) return;

    final velocity = details.primaryVelocity ?? 0;
    final threshold = _dragViewportWidth * 0.22;
    final goNext = velocity < -500 || _horizontalDragOffset <= -threshold;
    final goPrevious = velocity > 500 || _horizontalDragOffset >= threshold;

    if (goNext) {
      await _completeSwipeNavigation(goNext: true);
      return;
    }

    if (goPrevious) {
      await _completeSwipeNavigation(goNext: false);
      return;
    }

    await _animateDragOffsetTo(0);
  }

  Widget _buildBeltBackdrop(BuildContext context, double width) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_horizontalDragOffset / width).clamp(-1.0, 1.0);
    final base = colorScheme.surfaceContainerHighest;
    final topLeft = Color.lerp(
      base.withOpacity(0.18),
      colorScheme.surface.withOpacity(0.26),
      (progress.abs() * 0.6).clamp(0.0, 1.0),
    )!;
    final bottomRight = Color.lerp(
      colorScheme.surface.withOpacity(0.08),
      base.withOpacity(0.16),
      (progress.abs() * 0.6).clamp(0.0, 1.0),
    )!;

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [topLeft, bottomRight],
          ),
        ),
      ),
    );
  }

  Future<void> _hydrateReadingPosition() async {
    final repository = ref.read(readingPositionRepositoryProvider);
    final lastReference = await repository.loadLastReference();
    if (lastReference != null) {
      ref.read(currentReferenceProvider.notifier).state = lastReference;
      final offset = await repository.loadChapterOffset(
        lastReference.book,
        lastReference.chapter,
      );
      ref.read(currentChapterScrollOffsetProvider.notifier).state = offset;
    }
    _hydratedReadingPosition = true;
  }

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsBottomSheet(),
    );
  }

  void _openBookSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: const BibleSelectorDialog(),
      ),
    );
  }

  void _openTranslationSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: const TranslationSelectorDialog(),
      ),
    );
  }

  void _openSearchBar() {
    if (!_showSearchBar) {
      setState(() => _showSearchBar = true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchBarKey.currentState?.openFromSearchButton();
    });
  }

  void _handleModeButtonVisibility({required bool readingMode}) {
    _modeButtonHideTimer?.cancel();

    if (!readingMode) {
      if (!_showModeToggleButton) {
        setState(() => _showModeToggleButton = true);
      }
      return;
    }

    if (!_showModeToggleButton) {
      setState(() => _showModeToggleButton = true);
    }

    _modeButtonHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showModeToggleButton = false);
    });
  }

  void _toggleReadingMode(AppSettings settings) {
    final next = !settings.readingMode;
    ref.read(appSettingsProvider.notifier).state = settings.copyWith(
      readingMode: next,
    );
    _handleModeButtonVisibility(readingMode: next);
  }

  String _chapterKey(BibleReference reference) {
    return '${reference.book}|${reference.chapter}';
  }

  Future<void> _markChapterReadFromBottom() async {
    final reference = ref.read(currentReferenceProvider);
    final key = _chapterKey(reference);
    if (_bottomMarkedChapterKey == key) return;

    final readChapterKeys = ref
        .read(readingPlanControllerProvider)
        .readChapterKeys;
    if (readChapterKeys.contains(key)) {
      _bottomMarkedChapterKey = key;
      return;
    }

    _bottomMarkedChapterKey = key;
    await ref
        .read(readingPlanControllerProvider.notifier)
        .markChapterRead(reference.book, reference.chapter);
  }

  void _handleReadingModeFromVerticalScroll(
    double offset,
    AppSettings settings,
  ) {
    if (!_hasObservedChapterScroll) {
      _hasObservedChapterScroll = true;
      _lastObservedChapterOffset = offset;
      return;
    }

    final delta = offset - _lastObservedChapterOffset;
    _lastObservedChapterOffset = offset;

    if (delta > 34) {
      final now = DateTime.now();
      final withinWindow =
          _lastUpwardReadSwipeAt != null &&
          now.difference(_lastUpwardReadSwipeAt!) <= const Duration(seconds: 2);
      _upwardReadSwipes = withinWindow ? _upwardReadSwipes + 1 : 1;
      _lastUpwardReadSwipeAt = now;

      if (!settings.readingMode && _upwardReadSwipes >= 2) {
        ref.read(appSettingsProvider.notifier).state = settings.copyWith(
          readingMode: true,
        );
        _handleModeButtonVisibility(readingMode: true);
        _upwardReadSwipes = 0;
      }
      return;
    }

    if (delta < -20) {
      _upwardReadSwipes = 0;
    }
  }

  void _goToNextChapterAcrossBooks(BibleReference currentReference) {
    final currentBook = BibleBooks.findByName(currentReference.book);
    if (currentBook == null) return;

    final nextChapter = currentReference.chapter + 1;
    if (nextChapter <= currentBook.chapters) {
      ref.read(currentReferenceProvider.notifier).state = currentReference
          .copyWith(chapter: nextChapter, verse: 1);
      return;
    }

    final currentBookIndex = BibleBooks.all.indexWhere(
      (book) => book.name == currentReference.book,
    );
    if (currentBookIndex < 0 || currentBookIndex >= BibleBooks.all.length - 1) {
      return;
    }

    final nextBook = BibleBooks.all[currentBookIndex + 1];
    ref.read(currentReferenceProvider.notifier).state = BibleReference(
      book: nextBook.name,
      chapter: 1,
      verse: 1,
    );
  }

  void _goToPreviousChapterAcrossBooks(BibleReference currentReference) {
    final previousChapter = currentReference.chapter - 1;
    if (previousChapter >= 1) {
      ref.read(currentReferenceProvider.notifier).state = currentReference
          .copyWith(chapter: previousChapter, verse: 1);
      return;
    }

    final currentBookIndex = BibleBooks.all.indexWhere(
      (book) => book.name == currentReference.book,
    );
    if (currentBookIndex <= 0) return;

    final previousBook = BibleBooks.all[currentBookIndex - 1];
    ref.read(currentReferenceProvider.notifier).state = BibleReference(
      book: previousBook.name,
      chapter: previousBook.chapters,
      verse: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appSettingsProvider, (previous, next) {
      if (previous?.readingMode != next.readingMode) {
        _handleModeButtonVisibility(readingMode: next.readingMode);
      }
    });

    ref.listen(currentReferenceProvider, (previous, next) {
      Future.microtask(() {
        _hasObservedChapterScroll = false;
        _lastObservedChapterOffset = 0;
        _upwardReadSwipes = 0;
        _lastUpwardReadSwipeAt = null;
        _bottomMarkedChapterKey = null;

        if (_hydratedReadingPosition) {
          final repository = ref.read(readingPositionRepositoryProvider);
          repository.saveLastReference(next);
          repository.loadChapterOffset(next.book, next.chapter).then((offset) {
            ref.read(currentChapterScrollOffsetProvider.notifier).state =
                offset;
          });
        }
      });
    });

    final currentReference = ref.watch(currentReferenceProvider);
    final currentTranslation = ref.watch(currentTranslationProvider);
    final chapterVerses = ref.watch(currentChapterVersesProvider);
    final chapterScrollOffset = ref.watch(currentChapterScrollOffsetProvider);
    final targetVerse = ref.watch(targetVerseInChapterProvider);
    final settings = ref.watch(appSettingsProvider);
    final fontSize = settings.fontSize;

    // Extract translation name for display
    final translationName = currentTranslation
        .replaceAll('.json', '')
        .replaceAll('HOLMAN CHRISTIAN STANDARD BIBLE', 'HCSB')
        .replaceAll('KING JAMES BIBLE', 'KJV')
        .replaceAll('NEW INTERNATIONAL VERSION', 'NIV')
        .replaceAll('ENGLISH STANDARD VERSION', 'ESV')
        .replaceAll('NEW LIVING TRANSLATION', 'NLT')
        .replaceAll('NEW AMERICAN STANDARD BIBLE', 'NASB');

    return Scaffold(
      appBar: settings.readingMode
          ? null
          : AppBar(
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centers the entire group
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openBookSelector(context),
                    child: Text(
                      '${currentReference.book} ${currentReference.chapter}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Fixed small space between the texts
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openTranslationSelector(context),
                    child: Text(
                      translationName.length > 30
                          ? '${translationName.substring(0, 30)}...'
                          : translationName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert), // The three dots
                  onSelected: (String value) {
                    // Handle the selected option
                    switch (value) {
                      case 'reading_plan':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadingPlanScreen(),
                          ),
                        );
                        break;
                      case 'insights':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadingInsightsScreen(),
                          ),
                        );
                        break;
                      case 'settings':
                        _openSettingsSheet(context);
                        break;
                      case 'notifications':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                        break;
                      case 'about':
                        showAboutDialog(
                          context: context,
                          applicationName: 'Living Word',
                          applicationVersion: '1.0.0',
                        );
                        break;
                      case 'help':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Help'),
                            content: const Text(
                              'Swipe left/right to navigate chapters\n'
                              'Pinch to zoom for font size\n'
                              'Use search to find verses\n'
                              'Tap book selector to jump to any chapter',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'reading_plan',
                      child: Row(
                        children: [
                          Icon(Icons.menu_book),
                          SizedBox(width: 12),
                          Text('Reading Plan'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'insights',
                      child: Row(
                        children: [
                          Icon(Icons.insights),
                          SizedBox(width: 12),
                          Text('Insights'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'notifications',
                      child: Row(
                        children: [
                          Icon(Icons.notifications),
                          SizedBox(width: 12),
                          Text('Notifications'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 12),
                          Text('About'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'help',
                      child: Row(
                        children: [
                          Icon(Icons.help_outline),
                          SizedBox(width: 12),
                          Text('Help'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                // Bible verses with swipe navigation
                Expanded(
                  child: Builder(
                    builder: (context) {
                      double baseScale = 1.0;

                      return Column(
                        children: [
                          if (!settings.readingMode)
                            BibleSearchBar(
                              key: _searchBarKey,
                              isVisible: _showSearchBar,
                              onClose: () {
                                setState(() => _showSearchBar = false);
                              },
                            ),
                          Expanded(
                            child: GestureDetector(
                              // Horizontal swipe for chapter navigation
                              onHorizontalDragUpdate: (details) =>
                                  _handleHorizontalDragUpdate(
                                    details,
                                    settings,
                                  ),
                              onHorizontalDragEnd: (details) =>
                                  _handleHorizontalDragEnd(details),
                              // Pinch to zoom for font size
                              onScaleStart: (details) {
                                baseScale = fontSize / 16.0;
                              },
                              onScaleUpdate: (details) {
                                // Calculate new font size based on scale
                                final newSize =
                                    (16.0 * baseScale * details.scale).clamp(
                                      10.0,
                                      32.0,
                                    );
                                ref.read(appSettingsProvider.notifier).state =
                                    settings.copyWith(fontSize: newSize);
                              },
                              onScaleEnd: (details) {
                                // Show toast with final font size
                                final finalSize = ref
                                    .read(appSettingsProvider)
                                    .fontSize;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Font Size: ${finalSize.toStringAsFixed(0)}',
                                      textAlign: TextAlign.center,
                                    ),
                                    duration: const Duration(milliseconds: 800),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.only(
                                      top: 80,
                                      left: 20,
                                      right: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                  ),
                                );
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  _dragViewportWidth = constraints.maxWidth;
                                  final width = _dragViewportWidth <= 0
                                      ? 1.0
                                      : _dragViewportWidth;
                                  final progress =
                                      (_horizontalDragOffset / width).clamp(
                                        -1.0,
                                        1.0,
                                      );
                                  final pageTilt = -progress * 0.12;

                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _buildBeltBackdrop(context, width),
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..translate(_horizontalDragOffset)
                                          ..rotateY(pageTilt),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.09,
                                                ),
                                                blurRadius: 18,
                                                offset: Offset(
                                                  -progress * 12,
                                                  8,
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: chapterVerses.when(
                                            data: (verses) {
                                              if (verses.isEmpty) {
                                                return const Center(
                                                  child: Text(
                                                    'No verses found',
                                                  ),
                                                );
                                              }

                                              return VerseListWidget(
                                                verses: verses,
                                                fontSize: fontSize,
                                                lineSpacing:
                                                    settings.lineSpacing,
                                                fontFamily: settings.fontFamily,
                                                showVerseNumbers:
                                                    settings.showVerseNumbers,
                                                verseTextAlignment:
                                                    settings.verseTextAlignment,
                                                readingMode:
                                                    settings.readingMode,
                                                autoScroll: settings.autoScroll,
                                                autoScrollSpeed:
                                                    settings.autoScrollSpeed,
                                                initialScrollOffset:
                                                    chapterScrollOffset,
                                                targetVerseNumber: targetVerse,
                                                onTargetVerseHandled: () {
                                                  ref
                                                          .read(
                                                            targetVerseInChapterProvider
                                                                .notifier,
                                                          )
                                                          .state =
                                                      null;
                                                },
                                                onScrollOffsetChanged: (offset) {
                                                  ref
                                                          .read(
                                                            currentChapterScrollOffsetProvider
                                                                .notifier,
                                                          )
                                                          .state =
                                                      offset;
                                                  _handleReadingModeFromVerticalScroll(
                                                    offset,
                                                    settings,
                                                  );

                                                  if (!_hydratedReadingPosition) {
                                                    return;
                                                  }
                                                  final repository = ref.read(
                                                    readingPositionRepositoryProvider,
                                                  );
                                                  final current = ref.read(
                                                    currentReferenceProvider,
                                                  );
                                                  repository.saveChapterOffset(
                                                    current.book,
                                                    current.chapter,
                                                    offset,
                                                  );

                                                  if (settings.readingMode) {
                                                    _handleModeButtonVisibility(
                                                      readingMode: true,
                                                    );
                                                  }
                                                },
                                                onReachedChapterBottom: () {
                                                  _markChapterReadFromBottom();
                                                },
                                              );
                                            },
                                            loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            error: (error, stack) => Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.error_outline,
                                                      size: 48,
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Error loading verses',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      error.toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          if (!settings.readingMode)
            FutureBuilder<bool>(
              future: NavigationUtils.hasSystemNavBar(),
              builder: (context, snapshot) {
                final hasNavBar = snapshot.data ?? false;
                final navInset = MediaQuery.of(context).padding.bottom;
                final bottomPadding = hasNavBar ? (navInset + 8.0) : 8.0;
                return Positioned(
                  left: 24,
                  right: 24,
                  bottom: bottomPadding,
                  child: NavigationControls(
                    onSelectBook: () => _openBookSelector(context),
                    onSearch: _openSearchBar,
                    onSelectTranslation: () =>
                        _openTranslationSelector(context),
                  ),
                );
              },
            ),
          if (_showModeToggleButton)
            FutureBuilder<bool>(
              future: NavigationUtils.hasSystemNavBar(),
              builder: (context, snapshot) {
                final hasNavBar = snapshot.data ?? false;
                final navInset = MediaQuery.of(context).padding.bottom;
                final tabsHeight = settings.readingMode ? 0.0 : 68.0;
                final bottom = (hasNavBar ? navInset : 0.0) + tabsHeight + 10.0;

                return Positioned(
                  right: 16,
                  bottom: bottom,
                  child: FloatingActionButton.small(
                    heroTag: 'mode_toggle',
                    onPressed: () => _toggleReadingMode(settings),
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    child: Icon(
                      settings.readingMode
                          ? Icons.menu_book_outlined
                          : Icons.chrome_reader_mode,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
