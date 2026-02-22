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

  @override
  void initState() {
    super.initState();
    selectedBook = null;
  }

  @override
  Widget build(BuildContext context) {
    final chapterCount = selectedBook != null
        ? BibleBooks.findByName(selectedBook!)?.chapters ?? 0
        : 0;

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 8),
            const Text('Book', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
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
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      title: Text(book.name),
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      onTap: () {
                        setState(() {
                          selectedBook = book.name;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            if (selectedBook != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Chapter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 176,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: chapterCount,
                  itemBuilder: (context, index) {
                    final chapter = index + 1;

                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        ref
                            .read(currentReferenceProvider.notifier)
                            .state = BibleReference(
                          book: selectedBook!,
                          chapter: chapter,
                          verse: 1,
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$chapter',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
