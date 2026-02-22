import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bible_books.dart';
import '../providers/reading_plan_providers.dart';

class ReadingInsightsScreen extends ConsumerWidget {
  const ReadingInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingPlanControllerProvider);
    final service = ref.watch(readingPlanServiceProvider);

    if (state.isLoading) {
      return const Scaffold(
        appBar: _InsightsAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final chaptersRead = state.readChapterKeys.length;
    final streak = service.calculateStreak(state.readChapterDates);

    final otTotal = BibleBooks.oldTestament.fold<int>(
      0,
      (sum, book) => sum + book.chapters,
    );
    final ntTotal = BibleBooks.newTestament.fold<int>(
      0,
      (sum, book) => sum + book.chapters,
    );

    final otRead = state.readChapterKeys.where((key) {
      final book = key.split('|').first;
      final info = BibleBooks.findByName(book);
      return info?.isOldTestament ?? false;
    }).length;

    final ntRead = state.readChapterKeys.where((key) {
      final book = key.split('|').first;
      final info = BibleBooks.findByName(book);
      return info != null && !info.isOldTestament;
    }).length;

    final completedBooks = BibleBooks.all
        .where(
          (book) => List.generate(book.chapters, (idx) => idx + 1).every(
            (chapter) =>
                state.readChapterKeys.contains('${book.name}|$chapter'),
          ),
        )
        .length;

    final activePlans = state.activePlans.length;
    final otPercent = otTotal == 0 ? 0.0 : (otRead / otTotal);
    final ntPercent = ntTotal == 0 ? 0.0 : (ntRead / ntTotal);
    final totalChapters = otTotal + ntTotal;
    final overallPercent = totalChapters == 0
        ? 0.0
        : (chaptersRead / totalChapters);

    return Scaffold(
      appBar: const _InsightsAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatStrip(
            items: [
              _StatItem(label: 'Chapters Read', value: '$chaptersRead'),
              _StatItem(label: 'Books Completed', value: '$completedBooks/66'),
              _StatItem(label: 'Streak', value: '$streak days'),
              _StatItem(label: 'Active Plans', value: '$activePlans'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Progress Pie',
            subtitle: 'Old Testament vs New Testament contribution',
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        values: [otRead.toDouble(), ntRead.toDouble()],
                        colors: const [Color(0xFF4CAF50), Color(0xFF2196F3)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendRow(
                          color: const Color(0xFF4CAF50),
                          label: 'OT',
                          value: '$otRead',
                        ),
                        const SizedBox(height: 8),
                        _LegendRow(
                          color: const Color(0xFF2196F3),
                          label: 'NT',
                          value: '$ntRead',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text('OT: ${(otPercent * 100).toStringAsFixed(1)}%'),
                        Text('NT: ${(ntPercent * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Bar Chart',
            subtitle: 'Completion by section',
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _BarChartPainter(
                  labels: const ['OT', 'NT', 'Overall'],
                  values: [otPercent, ntPercent, overallPercent],
                  colors: const [
                    Color(0xFF4CAF50),
                    Color(0xFF2196F3),
                    Color(0xFFFFA726),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Progress Ring',
            subtitle: 'Global chapter completion diagram',
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _RingChartPainter(progress: overallPercent),
                    child: Center(
                      child: Text(
                        '${(overallPercent * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Summary: $chaptersRead / $totalChapters chapters complete',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Fulfilled Days',
            subtitle: 'Daily completion trail (last 30 days)',
            child: _FulfilledDaysGrid(readChapterDates: state.readChapterDates),
          ),
        ],
      ),
    );
  }
}

class _InsightsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _InsightsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Reading Insights'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(value),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});
}

class _StatStrip extends StatelessWidget {
  final List<_StatItem> items;

  const _StatStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FulfilledDaysGrid extends StatelessWidget {
  final Map<String, String> readChapterDates;

  const _FulfilledDaysGrid({required this.readChapterDates});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final completedDates = readChapterDates.values
        .map(DateTime.parse)
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet();

    final days = List.generate(30, (index) {
      final day = now.subtract(Duration(days: 29 - index));
      return DateTime(day.year, day.month, day.day);
    });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final fulfilled = completedDates.contains(day);
        return Tooltip(
          message: '${day.month}/${day.day}',
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fulfilled
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFFE0E0E0),
              boxShadow: fulfilled
                  ? const [
                      BoxShadow(
                        color: Color(0x66FFD54F),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
              border: Border.all(
                color: fulfilled
                    ? const Color(0xFFFFA000)
                    : const Color(0xFFBDBDBD),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 8,
    );

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final List<Color> colors;

  _BarChartPainter({
    required this.labels,
    required this.values,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const labelHeight = 22.0;
    const horizontalPadding = 10.0;
    const topPadding = 8.0;

    final chartWidth = size.width - (horizontalPadding * 2);
    final chartHeight = size.height - labelHeight - topPadding;
    final slotWidth = chartWidth / values.length;
    final barWidth = slotWidth * 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var i = 0; i < values.length; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final left =
          horizontalPadding + (i * slotWidth) + ((slotWidth - barWidth) / 2);
      final barHeight = chartHeight * value;
      final top = topPadding + (chartHeight - barHeight);
      final rect = Rect.fromLTWH(left, top, barWidth, barHeight);

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors[i % colors.length].withOpacity(0.7),
            colors[i % colors.length],
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(rect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      );
      textPainter.layout(minWidth: slotWidth, maxWidth: slotWidth);
      textPainter.paint(
        canvas,
        Offset(
          horizontalPadding + (i * slotWidth),
          topPadding + chartHeight + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}

class _RingChartPainter extends CustomPainter {
  final double progress;

  _RingChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final background = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final foreground = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFA726), Color(0xFFFF5722)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, background);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      (progress.clamp(0.0, 1.0)) * math.pi * 2,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _RingChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
