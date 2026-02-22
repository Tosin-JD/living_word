import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_settings.dart';
import '../models/verse.dart';

class VerseListWidget extends ConsumerStatefulWidget {
  final List<Verse> verses;
  final double fontSize;
  final double lineSpacing;
  final String fontFamily;
  final bool showVerseNumbers;
  final VerseTextAlignment verseTextAlignment;
  final bool readingMode;
  final bool autoScroll;
  final double autoScrollSpeed;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;
  final VoidCallback? onReachedChapterBottom;
  final int? targetVerseNumber;
  final VoidCallback? onTargetVerseHandled;

  const VerseListWidget({
    super.key,
    required this.verses,
    this.fontSize = 16.0,
    this.lineSpacing = 1.6,
    this.fontFamily = 'System',
    this.showVerseNumbers = true,
    this.verseTextAlignment = VerseTextAlignment.left,
    this.readingMode = false,
    this.autoScroll = false,
    this.autoScrollSpeed = 12.0,
    this.initialScrollOffset = 0.0,
    this.onScrollOffsetChanged,
    this.onReachedChapterBottom,
    this.targetVerseNumber,
    this.onTargetVerseHandled,
  });

  @override
  ConsumerState<VerseListWidget> createState() => _VerseListWidgetState();
}

class _VerseListWidgetState extends ConsumerState<VerseListWidget> {
  static const _scrollInterval = Duration(milliseconds: 16);

  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  Timer? _scrollUpdateDebounce;
  final Map<int, GlobalKey> _verseItemKeys = <int, GlobalKey>{};
  final Set<int> _selectedVerseNumbers = <int>{};
  bool _wasAtChapterBottom = false;

  bool get _isSelectionMode => _selectedVerseNumbers.isNotEmpty;

  String? _resolveFontFamily() {
    switch (widget.fontFamily) {
      case 'Sans Serif':
      case 'Sans-serif':
        return 'sans-serif';
      case 'Serif':
        return 'serif';
      case 'Monospace':
        return 'monospace';
      case 'Roboto':
      case 'Open Sans':
      case 'Lato':
      case 'Montserrat':
      case 'Merriweather':
      case 'Georgia':
        return widget.fontFamily;
      default:
        return null;
    }
  }

  List<String>? _resolveFontFallback() {
    switch (widget.fontFamily) {
      case 'Sans Serif':
      case 'Sans-serif':
        return const ['Roboto', 'Arial', 'Helvetica', 'sans-serif'];
      case 'Serif':
        return const ['Georgia', 'Times New Roman', 'serif'];
      case 'Monospace':
        return const ['Courier New', 'monospace'];
      case 'Roboto':
        return const ['Arial', 'Helvetica', 'sans-serif'];
      case 'Open Sans':
      case 'Lato':
      case 'Montserrat':
        return const ['Roboto', 'Arial', 'sans-serif'];
      case 'Merriweather':
      case 'Georgia':
        return const ['Times New Roman', 'serif'];
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    _scrollController.addListener(_handleScrollOffsetChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.autoScroll) {
        _startAutoScroll();
      }
      _scrollToTargetVerse();
    });
  }

  @override
  void didUpdateWidget(covariant VerseListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoScroll && !oldWidget.autoScroll) {
      _startAutoScroll();
    } else if (!widget.autoScroll && oldWidget.autoScroll) {
      _stopAutoScroll();
    }

    final oldBook = oldWidget.verses.isNotEmpty
        ? oldWidget.verses.first.reference.book
        : null;
    final oldChapter = oldWidget.verses.isNotEmpty
        ? oldWidget.verses.first.reference.chapter
        : null;
    final newBook = widget.verses.isNotEmpty
        ? widget.verses.first.reference.book
        : null;
    final newChapter = widget.verses.isNotEmpty
        ? widget.verses.first.reference.chapter
        : null;

    final chapterChanged = oldBook != newBook || oldChapter != newChapter;
    if (chapterChanged) {
      _selectedVerseNumbers.clear();
      _wasAtChapterBottom = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final target = widget.initialScrollOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.jumpTo(target);
      });
    }

    if (widget.targetVerseNumber != null &&
        widget.targetVerseNumber != oldWidget.targetVerseNumber) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToTargetVerse(),
      );
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _scrollUpdateDebounce?.cancel();
    _scrollController.removeListener(_handleScrollOffsetChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrollOffsetChange() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    final isAtBottom = maxExtent > 0 && position.pixels >= (maxExtent - 18);

    if (isAtBottom && !_wasAtChapterBottom) {
      _wasAtChapterBottom = true;
      widget.onReachedChapterBottom?.call();
    } else if (!isAtBottom) {
      _wasAtChapterBottom = false;
    }

    if (widget.onScrollOffsetChanged == null) return;
    _scrollUpdateDebounce?.cancel();
    _scrollUpdateDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || !_scrollController.hasClients) return;
      widget.onScrollOffsetChanged!(_scrollController.offset);
    });
  }

  void _scrollToTargetVerse() {
    final target = widget.targetVerseNumber;
    if (target == null) return;

    final key = _verseItemKeys[target];
    final targetContext = key?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.12,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    widget.onTargetVerseHandled?.call();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_scrollInterval, (_) {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final step =
          widget.autoScrollSpeed * (_scrollInterval.inMilliseconds / 1000);
      final nextOffset = (position.pixels + step).clamp(
        0.0,
        position.maxScrollExtent,
      );

      if (nextOffset >= position.maxScrollExtent) {
        _stopAutoScroll();
        return;
      }

      _scrollController.jumpTo(nextOffset);
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _toggleVerseSelection(Verse verse) {
    if (_selectedVerseNumbers.contains(verse.reference.verse)) {
      _selectedVerseNumbers.remove(verse.reference.verse);
    } else {
      _selectedVerseNumbers.add(verse.reference.verse);
    }
    if (_selectedVerseNumbers.isNotEmpty) {
      _stopAutoScroll();
    }
    setState(() {});
  }

  void _clearSelection() {
    if (_selectedVerseNumbers.isEmpty) return;
    setState(() => _selectedVerseNumbers.clear());
  }

  List<Verse> _selectedVerses() {
    final selected = widget.verses
        .where((v) => _selectedVerseNumbers.contains(v.reference.verse))
        .toList();
    selected.sort((a, b) => a.reference.verse.compareTo(b.reference.verse));
    return selected;
  }

  String _buildSelectionText(List<Verse> verses) {
    if (verses.isEmpty) return '';

    final groups = <List<Verse>>[];
    var currentGroup = <Verse>[verses.first];

    for (var i = 1; i < verses.length; i++) {
      final previous = verses[i - 1];
      final current = verses[i];

      final sameBook = previous.reference.book == current.reference.book;
      final sameChapter =
          previous.reference.chapter == current.reference.chapter;
      final contiguous =
          previous.reference.verse + 1 == current.reference.verse;

      if (sameBook && sameChapter && contiguous) {
        currentGroup.add(current);
      } else {
        groups.add(currentGroup);
        currentGroup = [current];
      }
    }
    groups.add(currentGroup);

    return groups.map(_formatVerseGroup).join('\n\n');
  }

  String _formatVerseGroup(List<Verse> group) {
    final first = group.first;
    final last = group.last;
    final joinedText = group.map((verse) => verse.text.trim()).join(' ');

    final reference = first.reference.verse == last.reference.verse
        ? '${first.reference.book} ${first.reference.chapter}:${first.reference.verse}'
        : '${first.reference.book} ${first.reference.chapter}:${first.reference.verse}-${last.reference.verse}';

    return '"$joinedText" — $reference';
  }

  Future<void> _copySelection() async {
    final selected = _selectedVerses();
    if (selected.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: _buildSelectionText(selected)));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selected.length == 1
              ? 'Verse copied'
              : '${selected.length} verses copied',
        ),
      ),
    );
  }

  Future<void> _shareSelection() async {
    final selected = _selectedVerses();
    if (selected.isEmpty) return;

    final text = _buildSelectionText(selected);

    try {
      await Share.share(text);
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Share is unavailable right now. Text copied instead. '
            'Do a full restart of the app.',
          ),
        ),
      );
    } on PlatformException {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share failed on this device. Text copied instead.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedFontFamily = _resolveFontFamily();
    final resolvedFontFallback = _resolveFontFallback();
    final textAlign = widget.verseTextAlignment == VerseTextAlignment.justify
        ? TextAlign.justify
        : TextAlign.left;
    final safeBottomInset = MediaQuery.of(context).padding.bottom;
    const chapterOverlayClearance = 110.0;
    const selectionToolbarExtraClearance = 176.0;
    final chapterTopPadding = widget.readingMode ? 72.0 : 28.0;
    final showChapterOneHeader =
        widget.verses.isNotEmpty && widget.verses.first.reference.chapter == 1;
    final chapterTitle = showChapterOneHeader
        ? '${widget.verses.first.reference.book} 1'
        : null;
    final bottomPadding =
        chapterOverlayClearance +
        safeBottomInset +
        (_isSelectionMode ? selectionToolbarExtraClearance : 0);

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(10, 12, 10, bottomPadding),
          itemCount: widget.verses.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: chapterTopPadding),
                    if (showChapterOneHeader) ...[
                      Text(
                        chapterTitle!,
                        style: TextStyle(
                          fontSize: (widget.fontSize + 12).clamp(28.0, 44.0),
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          fontFamily: resolvedFontFamily,
                          fontFamilyFallback: resolvedFontFallback,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              );
            }

            final verse = widget.verses[index - 1];
            final verseKey = _verseItemKeys.putIfAbsent(
              verse.reference.verse,
              () => GlobalKey(),
            );
            final isSelected = _selectedVerseNumbers.contains(
              verse.reference.verse,
            );

            return Padding(
              key: verseKey,
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onLongPress: () => _toggleVerseSelection(verse),
                  onTap: _isSelectionMode
                      ? () => _toggleVerseSelection(verse)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showVerseNumbers)
                          SizedBox(
                            width: 20,
                            child: Text(
                              '${verse.reference.verse}',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: resolvedFontFamily,
                                fontFamilyFallback: resolvedFontFallback,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            verse.text,
                            textAlign: textAlign,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              height: widget.lineSpacing,
                              fontFamily: resolvedFontFamily,
                              fontFamilyFallback: resolvedFontFallback,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_isSelectionMode)
          Positioned(
            left: 12,
            right: 12,
            bottom: 124,
            child: SafeArea(
              top: false,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_selectedVerseNumbers.length} selected',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy',
                        onPressed: _copySelection,
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        tooltip: 'Share',
                        onPressed: _shareSelection,
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        tooltip: 'Close selection',
                        onPressed: _clearSelection,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
