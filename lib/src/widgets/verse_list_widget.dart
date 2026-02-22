import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/verse.dart';

class VerseListWidget extends ConsumerStatefulWidget {
  final List<Verse> verses;
  final double fontSize;
  final double lineSpacing;
  final String fontFamily;
  final bool showVerseNumbers;
  final bool autoScroll;
  final double autoScrollSpeed;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;
  final int? targetVerseNumber;
  final VoidCallback? onTargetVerseHandled;

  const VerseListWidget({
    super.key,
    required this.verses,
    this.fontSize = 16.0,
    this.lineSpacing = 1.6,
    this.fontFamily = 'System',
    this.showVerseNumbers = true,
    this.autoScroll = false,
    this.autoScrollSpeed = 12.0,
    this.initialScrollOffset = 0.0,
    this.onScrollOffsetChanged,
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

  @override
  Widget build(BuildContext context) {
    final resolvedFontFamily = _resolveFontFamily();
    final resolvedFontFallback = _resolveFontFallback();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.verses.length,
      itemBuilder: (context, index) {
        final verse = widget.verses[index];
        final verseKey = _verseItemKeys.putIfAbsent(
          verse.reference.verse,
          () => GlobalKey(),
        );
        return Padding(
          key: verseKey,
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse number
              if (widget.showVerseNumbers)
                Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
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
              // Verse text
              Expanded(
                child: SelectableText(
                  verse.text,
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
        );
      },
    );
  }
}
