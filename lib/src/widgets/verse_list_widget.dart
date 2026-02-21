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

  const VerseListWidget({
    super.key,
    required this.verses,
    this.fontSize = 16.0,
    this.lineSpacing = 1.6,
    this.fontFamily = 'System',
    this.showVerseNumbers = true,
    this.autoScroll = false,
    this.autoScrollSpeed = 12.0,
  });

  @override
  ConsumerState<VerseListWidget> createState() => _VerseListWidgetState();
}

class _VerseListWidgetState extends ConsumerState<VerseListWidget> {
  static const _scrollInterval = Duration(milliseconds: 16);

  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;

  String? _resolveFontFamily() {
    switch (widget.fontFamily) {
      case 'Serif':
        return 'serif';
      case 'Sans-serif':
        return 'sans-serif';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.autoScroll) {
        _startAutoScroll();
      }
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
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _scrollController.dispose();
    super.dispose();
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.verses.length,
      itemBuilder: (context, index) {
        final verse = widget.verses[index];
        return Padding(
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
