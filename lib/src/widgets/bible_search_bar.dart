import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result.dart';
import '../providers/bible_providers.dart';

/// Search bar rendered near the top and controlled by parent visibility.
class BibleSearchBar extends ConsumerStatefulWidget {
  const BibleSearchBar({super.key, required this.isVisible, this.onClose});

  final bool isVisible;
  final VoidCallback? onClose;

  @override
  ConsumerState<BibleSearchBar> createState() => BibleSearchBarState();
}

class BibleSearchBarState extends ConsumerState<BibleSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void focusInput() {
    if (!mounted) return;

    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  void runSearch(String query, {bool openResults = true, bool focus = false}) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    _controller.text = normalized;
    _controller.selection = TextSelection.collapsed(offset: normalized.length);

    if (focus) {
      focusInput();
    }

    _performSearch(openResults: openResults);
    setState(() {});
  }

  void openFromSearchButton() {
    final existingInBox = _controller.text.trim();
    final existingGlobal = ref.read(searchQueryProvider).trim();
    final candidate = existingInBox.isNotEmpty ? existingInBox : existingGlobal;

    if (candidate.isNotEmpty) {
      runSearch(candidate, openResults: true, focus: false);
      return;
    }

    focusInput();
  }

  Future<void> _performSearch({bool openResults = true}) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    ref.read(searchQueryProvider.notifier).state = query;
    final results = await ref.read(searchResultsProvider.future);
    if (results.isNotEmpty) {
      await ref.read(searchHistoryProvider.notifier).addQuery(query);
    }

    if (openResults) {
      _showSearchResults();
    }
  }

  void _showSearchResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _SearchResultsSheet(scrollController: scrollController);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState: widget.isVisible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search for verses, words, or references...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _focusNode.unfocus();
                        widget.onClose?.call();
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _performSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Search history',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(searchHistoryProvider.notifier).clearAll();
                          },
                          child: const Text('Clear history'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: history.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: InputChip(
                              label: Text(item),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onPressed: () {
                                runSearch(item, openResults: true);
                              },
                              onDeleted: () {
                                ref
                                    .read(searchHistoryProvider.notifier)
                                    .removeQuery(item);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      secondChild: const SizedBox.shrink(),
    );
  }
}

/// Search results sheet
class _SearchResultsSheet extends ConsumerWidget {
  const _SearchResultsSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Container(
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Search Results for "$searchQuery"',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: searchResults.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return _SearchResultTile(result: result);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends ConsumerWidget {
  const _SearchResultTile({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = result.verse;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          '${verse.reference.book} ${verse.reference.chapter}:${verse.reference.verse}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(verse.text, maxLines: 3, overflow: TextOverflow.ellipsis),
        ),
        onTap: () {
          ref.read(targetVerseInChapterProvider.notifier).state =
              verse.reference.verse;
          ref.read(currentReferenceProvider.notifier).state = verse.reference;
          Navigator.pop(context);
        },
      ),
    );
  }
}
