import 'package:flutter/material.dart';

/// Floating 3-action navigation bar shown above the bottom edge.
class NavigationControls extends StatelessWidget {
  const NavigationControls({
    super.key,
    required this.onSelectBook,
    required this.onSearch,
    required this.onSelectTranslation,
  });

  final VoidCallback onSelectBook;
  final VoidCallback onSearch;
  final VoidCallback onSelectTranslation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface.withOpacity(0.96),
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                tooltip: 'Select Book',
                onPressed: onSelectBook,
                icon: const Icon(Icons.menu_book_rounded),
              ),
            ),
            Expanded(
              child: IconButton.filled(
                tooltip: 'Search',
                onPressed: onSearch,
                icon: const Icon(Icons.search_rounded),
              ),
            ),
            Expanded(
              child: IconButton(
                tooltip: 'Select Translation',
                onPressed: onSelectTranslation,
                icon: const Icon(Icons.translate_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
