import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';

/// Search bar that rises above keyboard when focused
class BibleSearchBar extends ConsumerStatefulWidget {
  const BibleSearchBar({super.key});

  @override
  ConsumerState<BibleSearchBar> createState() => _BibleSearchBarState();
}

class _BibleSearchBarState extends ConsumerState<BibleSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search for verses, words, or references...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          // Fully rounded pill shape
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              30,
            ), // Increase for more rounding (e.g., 32 or 40)
            borderSide: BorderSide
                .none, // Optional: removes the outline stroke if you only want filled background
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.primary, // Optional: subtle focus outline
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ), // Helps with height and icon alignment
        ),
        onChanged: (value) => setState(() {}),
        onSubmitted: (value) => _performSearch(),
        textInputAction: TextInputAction.search,
      ),
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
          // Header
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

          // Results
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
                          // Navigate to the verse
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
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
