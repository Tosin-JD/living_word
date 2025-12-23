import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';
import '../data/bible_books.dart';
import '../models/bible_reference.dart';

/// Modal bottom sheet for selecting book, chapter, and verse
class BibleSelectorDialog extends ConsumerStatefulWidget {
  const BibleSelectorDialog({super.key});

  @override
  ConsumerState<BibleSelectorDialog> createState() =>
      _BibleSelectorDialogState();
}

class _BibleSelectorDialogState extends ConsumerState<BibleSelectorDialog> {
  String? selectedBook;
  int? selectedChapter;
  int? selectedVerse;

  @override
  void initState() {
    super.initState();
    final currentRef = ref.read(currentReferenceProvider);
    selectedBook = currentRef.book;
    selectedChapter = currentRef.chapter;
    selectedVerse = currentRef.verse;
  }

  @override
  Widget build(BuildContext context) {
    final chapterCount = selectedBook != null
        ? BibleBooks.findByName(selectedBook!)?.chapters ?? 0
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Reference',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Book selector
          const Text('Book', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: BibleBooks.all.length,
              itemBuilder: (context, index) {
                final book = BibleBooks.all[index];
                final isSelected = selectedBook == book.name;

                return ListTile(
                  title: Text(book.name),
                  selected: isSelected,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  onTap: () {
                    setState(() {
                      selectedBook = book.name;
                      selectedChapter = 1;
                      selectedVerse = 1;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Chapter and Verse selectors
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chapter',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedBook != null
                          ? GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4,
                                  ),
                              itemCount: chapterCount,
                              itemBuilder: (context, index) {
                                final chapter = index + 1;
                                final isSelected = selectedChapter == chapter;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedChapter = chapter;
                                      selectedVerse = 1;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : null,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$chapter',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : null,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(child: Text('Select a book first')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: selectedBook != null && selectedChapter != null
                    ? () {
                        ref
                            .read(currentReferenceProvider.notifier)
                            .state = BibleReference(
                          book: selectedBook!,
                          chapter: selectedChapter!,
                          verse: selectedVerse ?? 1,
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Go'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
