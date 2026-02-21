import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/verse_list_widget.dart';
import '../widgets/navigation_controls.dart';
import '../widgets/bible_search_bar.dart';
import '../utils/navigation_utils.dart';
import 'settings_screen.dart';

class BibleHomeScreen extends ConsumerWidget {
  const BibleHomeScreen({super.key});

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentReference = ref.watch(currentReferenceProvider);
    final currentTranslation = ref.watch(currentTranslationProvider);
    final chapterVerses = ref.watch(currentChapterVersesProvider);
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
                      case 'settings':
                        _openSettingsSheet(context);
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
          Column(
            children: [
              // Bible verses with swipe navigation
              Expanded(
                child: Builder(
                  builder: (context) {
                    double baseScale = 1.0;

                    return GestureDetector(
                      // Horizontal swipe for chapter navigation
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -500) {
                            // Swiped left - go to next chapter
                            final bookChapterCount = ref.read(
                              currentBookChapterCountProvider,
                            );
                            final newChapter = currentReference.chapter + 1;
                            if (newChapter <= bookChapterCount) {
                              ref
                                  .read(currentReferenceProvider.notifier)
                                  .state = currentReference.copyWith(
                                chapter: newChapter,
                                verse: 1,
                              );
                            }
                          } else if (details.primaryVelocity! > 500) {
                            // Swiped right - go to previous chapter
                            final newChapter = currentReference.chapter - 1;
                            if (newChapter >= 1) {
                              ref
                                  .read(currentReferenceProvider.notifier)
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
                        final newSize = (16.0 * baseScale * details.scale)
                            .clamp(10.0, 32.0);
                        ref.read(appSettingsProvider.notifier).state = settings
                            .copyWith(fontSize: newSize);
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
                            return const Center(child: Text('No verses found'));
                          }
                          return VerseListWidget(
                            verses: verses,
                            fontSize: fontSize,
                            lineSpacing: settings.lineSpacing,
                            fontFamily: settings.fontFamily,
                            showVerseNumbers: settings.showVerseNumbers,
                            autoScroll: settings.autoScroll,
                            autoScrollSpeed: settings.autoScrollSpeed,
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading verses',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!settings.readingMode) ...[
                const Divider(height: 1),

                // Navigation controls and search bar with conditional safe area
                FutureBuilder<bool>(
                  future: NavigationUtils.hasSystemNavBar(),
                  builder: (context, snapshot) {
                    final hasNavBar = snapshot.data ?? false;
                    final child = Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [NavigationControls(), BibleSearchBar()],
                    );

                    return hasNavBar
                        ? SafeArea(top: false, child: child)
                        : child;
                  },
                ),
              ],
            ],
          ),

          // Floating action buttons with safe area for Android nav bar
          // Floating action buttons with conditional safe area
          if (!settings.readingMode)
            FutureBuilder<bool>(
              future: NavigationUtils.hasSystemNavBar(),
              builder: (context, snapshot) {
                final hasNavBar = snapshot.data ?? false;
                final buttonsStack = Positioned.fill(
                  child: Stack(
                    children: [
                      // Previous button (left)
                      Positioned(
                        left: 16,
                        bottom: 160,
                        child: FloatingActionButton(
                          heroTag: 'previous',
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          elevation: 6,
                          shape: const CircleBorder(),
                          onPressed: () {
                            final newChapter = currentReference.chapter - 1;
                            if (newChapter >= 1) {
                              ref
                                  .read(currentReferenceProvider.notifier)
                                  .state = currentReference.copyWith(
                                chapter: newChapter,
                                verse: 1,
                              );
                            }
                          },
                          child: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                      ),

                      // Next button (right)
                      Positioned(
                        right: 16,
                        bottom: 160,
                        child: FloatingActionButton(
                          heroTag: 'next',
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          elevation: 6,
                          shape: const CircleBorder(),
                          onPressed: () {
                            final bookChapterCount = ref.read(
                              currentBookChapterCountProvider,
                            );
                            final newChapter = currentReference.chapter + 1;
                            if (newChapter <= bookChapterCount) {
                              ref
                                  .read(currentReferenceProvider.notifier)
                                  .state = currentReference.copyWith(
                                chapter: newChapter,
                                verse: 1,
                              );
                            }
                          },
                          child: const Icon(Icons.arrow_forward_ios, size: 20),
                        ),
                      ),
                    ],
                  ),
                );

                return hasNavBar
                    ? SafeArea(top: false, child: buttonsStack)
                    : buttonsStack;
              },
            ),
          if (settings.readingMode)
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: Material(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      _openSettingsSheet(context);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
