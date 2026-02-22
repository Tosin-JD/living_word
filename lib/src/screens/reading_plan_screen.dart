import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bible_books.dart';
import '../models/bible_reference.dart';
import '../models/reading_plan.dart';
import '../providers/bible_providers.dart';
import '../providers/reading_plan_providers.dart';
import '../services/reading_plan_service.dart';

class ReadingPlanScreen extends ConsumerStatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  ConsumerState<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends ConsumerState<ReadingPlanScreen> {
  String _systemStartBook = BibleBooks.all.first.name;
  String _selectedBook = BibleBooks.all.first.name;
  int _selectedDays = 14;
  final TextEditingController _customDaysController = TextEditingController();
  final TextEditingController _futureNameController = TextEditingController();
  final TextEditingController _futureDescriptionController =
      TextEditingController();
  final TextEditingController _futureDurationController = TextEditingController(
    text: '21',
  );
  _BookPlanPreset _bookPreset = _BookPlanPreset.single;
  _FuturePlanScope _futureScope = _FuturePlanScope.book;
  TestamentScope _futureTestament = TestamentScope.newTestament;
  PlanType _futurePlanType = PlanType.custom;
  PlanCategory _futureCategory = PlanCategory.devotional;
  final Set<String> _futureSelectedBooks = {'John'};

  @override
  void dispose() {
    _customDaysController.dispose();
    _futureNameController.dispose();
    _futureDescriptionController.dispose();
    _futureDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingPlanControllerProvider);
    final service = ref.watch(readingPlanServiceProvider);
    final currentReference = ref.watch(currentReferenceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Plan')),
      body: SafeArea(
        top: false,
        bottom: true,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader(
                    context,
                    'Active Plans',
                    Icons.event_note,
                  ),
                  if (state.activePlans.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('No active plans yet'),
                        subtitle: Text('Start one below.'),
                      ),
                    )
                  else
                    ...state.activePlans.map(
                      (plan) => _buildActivePlanCard(
                        context,
                        plan,
                        state,
                        service,
                        currentReference.book,
                      ),
                    ),

                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    context,
                    'System Plans',
                    Icons.auto_awesome,
                  ),
                  _buildTemplateButtons(context, service),

                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    context,
                    'Book Plans',
                    Icons.library_books,
                  ),
                  _buildBookPlanComposer(context, service),

                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    context,
                    'Recommendations',
                    Icons.recommend,
                  ),
                  _buildRecommendations(service, state),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Future', Icons.upcoming),
                  _buildFuturePlanBuilder(context, service),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(
    BuildContext context,
    ReadingPlan plan,
    ReadingPlanState state,
    ReadingPlanService service,
    String currentBookName,
  ) {
    final progress = service.calculateProgress(
      plan: plan,
      readChapterKeys: state.readChapterKeys,
    );

    final nextChapter = service.resolveNextChapterForPlan(
      plan: plan,
      readChapterKeys: state.readChapterKeys,
      readChapterDates: state.readChapterDates,
      preferredBookName: currentBookName,
    );
    if (nextChapter == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(plan.description),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.percentCompleted / 100),
            const SizedBox(height: 8),
            Text(
              'Progress: ${progress.percentCompleted.toStringAsFixed(1)}% '
              '(${progress.readChapters}/${progress.totalChapters} chapters)',
            ),
            Text(
              'Days completed: ${progress.completedDays}/${plan.durationDays} | '
              'Est. days remaining: ${progress.estimatedDaysRemaining}',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(currentReferenceProvider.notifier)
                        .state = BibleReference(
                      book: nextChapter.bookName,
                      chapter: nextChapter.chapter,
                      verse: 1,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Continue Reading'),
                ),
                OutlinedButton(
                  onPressed: () => ref
                      .read(readingPlanControllerProvider.notifier)
                      .removePlan(plan.id),
                  child: const Text('Restart Book Plan'),
                ),
                OutlinedButton(
                  onPressed: () => _showChangePaceDialog(context, plan),
                  child: const Text('Change Pace'),
                ),
                OutlinedButton(
                  onPressed: () => _showCalendarDialog(context, plan, state),
                  child: const Text('View Calendar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateButtons(
    BuildContext context,
    ReadingPlanService service,
  ) {
    final templates = service.getSystemTemplates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _systemStartBook,
          decoration: const InputDecoration(labelText: 'Start from book'),
          items: BibleBooks.all
              .map(
                (book) =>
                    DropdownMenuItem(value: book.name, child: Text(book.name)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _systemStartBook = value);
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: templates.map((template) {
            return ActionChip(
              label: Text(template.name),
              onPressed: () {
                final plan = service.buildFromTemplateWithStart(
                  template,
                  startBookName: _systemStartBook,
                );
                ref
                    .read(readingPlanControllerProvider.notifier)
                    .startPlan(plan);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookPlanComposer(
    BuildContext context,
    ReadingPlanService service,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<_BookPlanPreset>(
              value: _bookPreset,
              decoration: const InputDecoration(labelText: 'Plan kind'),
              items: const [
                DropdownMenuItem(
                  value: _BookPlanPreset.single,
                  child: Text('Single book'),
                ),
                DropdownMenuItem(
                  value: _BookPlanPreset.gospels,
                  child: Text('Multi-book: Gospels'),
                ),
                DropdownMenuItem(
                  value: _BookPlanPreset.majorProphets,
                  child: Text('Thematic: Major Prophets'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _bookPreset = value);
              },
            ),
            if (_bookPreset == _BookPlanPreset.single) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBook,
                decoration: const InputDecoration(labelText: 'Book'),
                items: BibleBooks.all
                    .map(
                      (book) => DropdownMenuItem(
                        value: book.name,
                        child: Text('${book.name} (${book.chapters} ch)'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedBook = value);
                },
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _durationChip(7),
                _durationChip(14),
                _durationChip(30),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: _selectedDays == -1,
                  onSelected: (_) => setState(() => _selectedDays = -1),
                ),
              ],
            ),
            if (_selectedDays == -1) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Custom duration (days)',
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final days = _resolvedDurationDays(context);
                if (days == null) return;

                final books = switch (_bookPreset) {
                  _BookPlanPreset.single => [_selectedBook],
                  _BookPlanPreset.gospels => [
                    'Matthew',
                    'Mark',
                    'Luke',
                    'John',
                  ],
                  _BookPlanPreset.majorProphets => [
                    'Isaiah',
                    'Jeremiah',
                    'Lamentations',
                    'Ezekiel',
                    'Daniel',
                  ],
                };

                final plan = service.createBookPlan(
                  bookNames: books,
                  durationDays: days,
                );
                ref
                    .read(readingPlanControllerProvider.notifier)
                    .startPlan(plan);
              },
              child: const Text('Start Book Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(
    ReadingPlanService service,
    ReadingPlanState state,
  ) {
    final keys = service.getRecommendedPlanKeys(
      readChapterKeys: state.readChapterKeys,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keys.map((key) {
        final label = switch (key) {
          'john_7' => 'Start with John in 7 Days',
          'psalms_30' => 'Read Psalms in 30 Days',
          'nt_90' => 'New Testament in 90 Days',
          _ => 'Recommended Plan',
        };

        return ActionChip(
          label: Text(label),
          onPressed: () {
            final plan = service.createRecommendedPlanFromKey(key);
            ref.read(readingPlanControllerProvider.notifier).startPlan(plan);
          },
        );
      }).toList(),
    );
  }

  Widget _buildFuturePlanBuilder(
    BuildContext context,
    ReadingPlanService service,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom User-Generated Plan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _futureNameController,
              decoration: const InputDecoration(labelText: 'Plan name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _futureDescriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<_FuturePlanScope>(
              value: _futureScope,
              decoration: const InputDecoration(labelText: 'Scope'),
              items: const [
                DropdownMenuItem(
                  value: _FuturePlanScope.fullBible,
                  child: Text('Full Bible'),
                ),
                DropdownMenuItem(
                  value: _FuturePlanScope.testament,
                  child: Text('Testament'),
                ),
                DropdownMenuItem(
                  value: _FuturePlanScope.book,
                  child: Text('Book / Multi-book'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _futureScope = value);
              },
            ),
            if (_futureScope == _FuturePlanScope.testament) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<TestamentScope>(
                value: _futureTestament,
                decoration: const InputDecoration(labelText: 'Testament'),
                items: const [
                  DropdownMenuItem(
                    value: TestamentScope.oldTestament,
                    child: Text('Old Testament'),
                  ),
                  DropdownMenuItem(
                    value: TestamentScope.newTestament,
                    child: Text('New Testament'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _futureTestament = value);
                },
              ),
            ],
            if (_futureScope == _FuturePlanScope.book) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: BibleBooks.all.map((book) {
                  final selected = _futureSelectedBooks.contains(book.name);
                  return FilterChip(
                    label: Text(book.name),
                    selected: selected,
                    onSelected: (on) {
                      setState(() {
                        if (on) {
                          _futureSelectedBooks.add(book.name);
                        } else {
                          _futureSelectedBooks.remove(book.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<PlanType>(
              value: _futurePlanType,
              decoration: const InputDecoration(labelText: 'Plan type'),
              items: PlanType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.name)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _futurePlanType = value);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PlanCategory>(
              value: _futureCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: PlanCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _futureCategory = value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _futureDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (days)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final duration =
                    int.tryParse(_futureDurationController.text.trim()) ?? 0;
                if (duration < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid duration for custom plan.'),
                    ),
                  );
                  return;
                }

                final name = _futureNameController.text.trim();
                final description = _futureDescriptionController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a plan name.')),
                  );
                  return;
                }

                ReadingPlan plan;
                switch (_futureScope) {
                  case _FuturePlanScope.fullBible:
                    plan = service.createFullBiblePlan(
                      durationDays: duration,
                      name: name,
                      description: description.isEmpty
                          ? 'Custom full Bible plan'
                          : description,
                      planType: _futurePlanType,
                      category: _futureCategory,
                    );
                    break;
                  case _FuturePlanScope.testament:
                    plan = service.createTestamentPlan(
                      testament: _futureTestament,
                      durationDays: duration,
                      name: name,
                      description: description.isEmpty
                          ? 'Custom testament plan'
                          : description,
                      planType: _futurePlanType,
                      category: _futureCategory,
                    );
                    break;
                  case _FuturePlanScope.book:
                    if (_futureSelectedBooks.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Select at least one book.'),
                        ),
                      );
                      return;
                    }
                    plan = service.createBookPlan(
                      bookNames: _futureSelectedBooks.toList(),
                      durationDays: duration,
                      customName: name,
                      customDescription: description.isEmpty
                          ? 'Custom book plan'
                          : description,
                      planType: _futurePlanType,
                      category: _futureCategory,
                    );
                    break;
                }

                ref
                    .read(readingPlanControllerProvider.notifier)
                    .startPlan(plan);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom plan created.')),
                );
              },
              child: const Text('Create Custom Plan'),
            ),
          ],
        ),
      ),
    );
  }

  ChoiceChip _durationChip(int days) {
    return ChoiceChip(
      label: Text('$days days'),
      selected: _selectedDays == days,
      onSelected: (_) => setState(() => _selectedDays = days),
    );
  }

  int? _resolvedDurationDays(BuildContext context) {
    if (_selectedDays > 0) return _selectedDays;

    final value = int.tryParse(_customDaysController.text.trim());
    if (value == null || value < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid custom duration.')),
      );
      return null;
    }
    return value;
  }

  Future<void> _showChangePaceDialog(
    BuildContext context,
    ReadingPlan plan,
  ) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Pace'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Remaining days'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final remainingDays = int.tryParse(controller.text.trim());
                if (remainingDays == null || remainingDays < 1) return;
                ref
                    .read(readingPlanControllerProvider.notifier)
                    .applyCatchUp(plan: plan, remainingDays: remainingDays);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showCalendarDialog(
    BuildContext context,
    ReadingPlan plan,
    ReadingPlanState state,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${plan.name} Calendar'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: plan.days.map((day) {
                  final completed = day.chapterRefs.every(
                    (ref) => state.readChapterKeys.contains(ref.key),
                  );

                  return FilterChip(
                    label: Text('Day ${day.dayNumber}'),
                    selected: completed,
                    onSelected: (_) {
                      if (!completed) {
                        ref
                            .read(readingPlanControllerProvider.notifier)
                            .markDayRead(day);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

enum _BookPlanPreset { single, gospels, majorProphets }

enum _FuturePlanScope { fullBible, testament, book }
