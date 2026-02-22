import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _performSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    ref.read(searchQueryProvider.notifier).state = query;
    _showSearchResults();
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
          return _SearchResultsSheet(
            scrollController: scrollController,
            query: _controller.text,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState: widget.isVisible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Padding(
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
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
      secondChild: const SizedBox.shrink(),
    );
  }
}

/// Search results sheet
class _SearchResultsSheet extends ConsumerWidget {
  final ScrollController scrollController;
  final String query;

  const _SearchResultsSheet({
    required this.scrollController,
    required this.query,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Search Results for "$query"',
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
          const SizedBox(height: 16),
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
                          child: Text(
                            verse.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onTap: () {
                          ref.read(currentReferenceProvider.notifier).state =
                              verse.reference;
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
