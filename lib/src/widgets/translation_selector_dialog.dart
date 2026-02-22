import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';

/// Dialog for selecting Bible translation
class TranslationSelectorDialog extends ConsumerWidget {
  const TranslationSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableTranslations = ref.watch(availableTranslationsProvider);
    final currentTranslation = ref.watch(currentTranslationProvider);

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
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
                  'Select Translation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Translation list
            Expanded(
              child: ListView.builder(
                itemCount: availableTranslations.length,
                itemBuilder: (context, index) {
                  final translation = availableTranslations[index];
                  final displayName = translation.replaceAll('.json', '');
                  final isSelected = currentTranslation == translation;

                  return ListTile(
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      ref.read(currentTranslationProvider.notifier).state =
                          translation;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
