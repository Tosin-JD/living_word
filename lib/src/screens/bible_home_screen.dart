import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
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

class _BibleHomeScreenState extends ConsumerState<BibleHomeScreen> {
  final GlobalKey<BibleSearchBarState> _searchBarKey =
      GlobalKey<BibleSearchBarState>();
  bool _showSearchBar = false;
  bool _hydratedReadingPosition = false;
  bool _showModeToggleButton = true;
  Timer? _modeButtonHideTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_hydrateReadingPosition);
  }

  @override
  void dispose() {
    _modeButtonHideTimer?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    ref.listen(appSettingsProvider, (previous, next) {
      if (previous?.readingMode != next.readingMode) {
        _handleModeButtonVisibility(readingMode: next.readingMode);
      }
    });

    ref.listen(currentReferenceProvider, (previous, next) {
      Future.microtask(() {
        ref
            .read(readingPlanControllerProvider.notifier)
            .markChapterRead(next.book, next.chapter);

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
                  Text(
                    '${currentReference.book} ${currentReference.chapter}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Fixed small space between the texts
                  Text(
                    translationName.length > 30
                        ? '${translationName.substring(0, 30)}...'
                        : translationName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              onHorizontalDragEnd: (details) {
                                if (details.primaryVelocity != null) {
                                  if (details.primaryVelocity! < -500) {
                                    // Swiped left - go to next chapter
                                    final bookChapterCount = ref.read(
                                      currentBookChapterCountProvider,
                                    );
                                    final newChapter =
                                        currentReference.chapter + 1;
                                    if (newChapter <= bookChapterCount) {
                                      ref
                                          .read(
                                            currentReferenceProvider.notifier,
                                          )
                                          .state = currentReference.copyWith(
                                        chapter: newChapter,
                                        verse: 1,
                                      );
                                    }
                                  } else if (details.primaryVelocity! > 500) {
                                    // Swiped right - go to previous chapter
                                    final newChapter =
                                        currentReference.chapter - 1;
                                    if (newChapter >= 1) {
                                      ref
                                          .read(
                                            currentReferenceProvider.notifier,
                                          )
                                          .state = currentReference.copyWith(
                                        chapter: newChapter,
                                        verse: 1,
                                      );
                                    }
                                  }
                                }
                              },
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
                              child: chapterVerses.when(
                                data: (verses) {
                                  if (verses.isEmpty) {
                                    return const Center(
                                      child: Text('No verses found'),
                                    );
                                  }

                                  return VerseListWidget(
                                    verses: verses,
                                    fontSize: fontSize,
                                    lineSpacing: settings.lineSpacing,
                                    fontFamily: settings.fontFamily,
                                    showVerseNumbers: settings.showVerseNumbers,
                                    autoScroll: settings.autoScroll,
                                    autoScrollSpeed: settings.autoScrollSpeed,
                                    initialScrollOffset: chapterScrollOffset,
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

                                      if (!_hydratedReadingPosition) return;
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
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, stack) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
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
                                          textAlign: TextAlign.center,
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
