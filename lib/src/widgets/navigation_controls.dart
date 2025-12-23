import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bible_selector_dialog.dart';
import 'translation_selector_dialog.dart';

/// Row containing navigation controls (book selector and translation selector)
class NavigationControls extends ConsumerWidget {
  const NavigationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Book/Chapter/Verse selector button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: const BibleSelectorDialog(),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Select Book/Chapter'),
            ),
          ),
          const SizedBox(width: 12),

          // Translation selector button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: const TranslationSelectorDialog(),
                  ),
                );
              },
              icon: const Icon(Icons.translate),
              label: const Text('Translation'),
            ),
          ),
        ],
      ),
    );
  }
}
