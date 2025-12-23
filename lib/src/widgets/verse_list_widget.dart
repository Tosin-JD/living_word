import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verse.dart';

class VerseListWidget extends ConsumerWidget {
  final List<Verse> verses;
  final double fontSize;

  const VerseListWidget({
    super.key,
    required this.verses,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse number
              Container(
                width: 40,
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  '${verse.reference.verse}',
                  style: TextStyle(
                    fontSize: 14,
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
                  style: TextStyle(fontSize: fontSize, height: 1.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
