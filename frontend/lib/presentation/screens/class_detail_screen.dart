import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grade/grade_calculator.dart';
import '../../domain/models/yiri_models.dart';
import '../../state/app_settings.dart';
import '../../state/classes_state.dart';
import '../theme/yiri_theme.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import '../widgets/yiri_card.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final classesState = ref.watch(classesProvider);
    final goal = ref.watch(appSettingsProvider).goalFinalGrade;

    final cls = classesState.classes.where((c) => c.id == widget.classId).cast<ClassSummary?>().firstOrNull;

    if (cls == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Class')),
        body: const Center(child: Text('Class not found. Pull to refresh on Dashboard.')),
      );
    }

    final snap = GradeCalculator.compute(cls: cls, goalFinalGrade: goal);

    final tabs = [
      _OverviewTab(cls: cls, snap: snap, goal: goal),
      _GradesTab(cls: cls),
      _EventsTab(cls: cls),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(cls.className, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: YiriTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  _TabPill(label: 'Overview', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                  _TabPill(label: 'Grades', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                  _TabPill(label: 'Events', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: tabs[_tab]),
            if (classesState.busy) const LinearProgressIndicator(minHeight: 3),
            if (classesState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(classesState.error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? YiriTheme.yiriRed.withOpacity(0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? YiriTheme.textBlack : YiriTheme.mutedText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final ClassSummary cls;
  final GradeSnapshot snap;
  final double goal;

  const _OverviewTab({required this.cls, required this.snap, required this.goal});

  @override
  Widget build(BuildContext context) {
    final currentStr = snap.current == null ? '—' : '${snap.current!.toStringAsFixed(1)}%';
    final projectedStr = snap.projected == null ? '—' : '${snap.projected!.toStringAsFixed(1)}%';

    return ListView(
      children: [
        const SectionHeader(
          title: 'At a glance',
          subtitle: 'Current performance, projection, and what you need to hit your goal.',
        ),
        const SizedBox(height: 14),
        YiriCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Metric(label: 'Current', value: currentStr),
                        const SizedBox(width: 18),
                        _Metric(label: 'Projected', value: projectedStr),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snap.requiredRemainingAverageForGoal == null
                          ? 'Add rubric categories (via syllabus) and grades to unlock goal math.'
                          : 'To hit ${goal.toStringAsFixed(0)}%, you need ~${snap.requiredRemainingAverageForGoal!.toStringAsFixed(1)}% on remaining categories.',
                      style: const TextStyle(color: YiriTheme.mutedText, height: 1.25),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: '${cls.categories.length} categories'),
                        _Chip(text: '${cls.events.length} events'),
                        _Chip(text: '${cls.grades.length} grades'),
                        _Chip(text: 'Assume ${cls.assumedRemainingAverage.toStringAsFixed(0)}% remaining'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ProgressRing(
                value: (snap.projected ?? 0) / 100,
                size: 66,
                stroke: 8,
                centerText: (snap.projected ?? 0).toStringAsFixed(0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (cls.categories.isNotEmpty)
          YiriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rubric', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                ...cls.categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        Text('${c.weight.toStringAsFixed(0)}%', style: const TextStyle(color: YiriTheme.mutedText, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GradesTab extends ConsumerWidget {
  final ClassSummary cls;

  const _GradesTab({required this.cls});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SectionHeader(
          title: 'Grades',
          subtitle: 'Enter graded work to improve current + projected results.',
        ),
        const SizedBox(height: 14),
        YiriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Gradebook', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                  FilledButton(
                    onPressed: () => _showAddGrade(context, ref, cls),
                    child: const Text('Add grade'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (cls.grades.isEmpty)
                const Text(
                  'No grades yet. Add your first score to start tracking your real-time standing.',
                  style: TextStyle(color: YiriTheme.mutedText, height: 1.25),
                )
              else
                Column(
                  children: [
                    for (final g in cls.grades.reversed.take(12)) ...[
                      _GradeRow(g: g),
                      const SizedBox(height: 10),
                    ]
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        YiriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Class actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text(
                'Deleting a class removes its rubric, events, and grades from your account.',
                style: TextStyle(color: YiriTheme.mutedText, height: 1.25),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Delete class?'),
                        content: Text('This will permanently delete “${cls.className}”.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    await ref.read(classesProvider.notifier).deleteClass(cls.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Delete class'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddGrade(BuildContext context, WidgetRef ref, ClassSummary cls) async {
    final title = TextEditingController();
    final earned = TextEditingController();
    final possible = TextEditingController(text: '100');

    final categories = <String>[
      ...cls.categories.map((c) => c.name),
      'Other',
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: YiriTheme.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final busy = ref.watch(classesProvider).busy;
            String selectedCategory = categories.isNotEmpty ? categories.first : 'Other';
            String? errorText;

            return StatefulBuilder(
              builder: (ctx, setModalState) {
                Future<void> save() async {
                  final evTitle = title.text.trim().isEmpty ? 'Grade item' : title.text.trim();
                  final e = double.tryParse(earned.text.trim());
                  final p = double.tryParse(possible.text.trim());

                  if (e == null || p == null) {
                    setModalState(() => errorText = 'Enter valid numbers for earned and out of.');
                    return;
                  }
                  if (p <= 0) {
                    setModalState(() => errorText = '“Out of” must be greater than 0.');
                    return;
                  }
                  if (e < 0 || e > p) {
                    setModalState(() => errorText = 'Earned must be between 0 and $p.');
                    return;
                  }

                  setModalState(() => errorText = null);

                  await ref.read(classesProvider.notifier).addGrade(
                        classId: cls.id,
                        eventTitle: evTitle,
                        category: selectedCategory.trim().isEmpty ? 'Other' : selectedCategory,
                        earned: e,
                        possible: p,
                      );

                  if (ctx.mounted) Navigator.of(ctx).pop();
                }

                return Padding(
                  padding: EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: 16,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add grade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: title,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Title', hintText: 'Quiz 2'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories
                            .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                            .toList(growable: false),
                        onChanged: busy
                            ? null
                            : (v) => setModalState(() {
                                  if (v != null) selectedCategory = v;
                                }),
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: earned,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Score earned', hintText: '18'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: possible,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Out of', hintText: '20'),
                            ),
                          ),
                        ],
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(errorText!, style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w800)),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : save,
                          child: Text(busy ? 'Saving…' : 'Save'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: busy ? null : () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    title.dispose();
    earned.dispose();
    possible.dispose();
  }
}

class _EventsTab extends StatelessWidget {
  final ClassSummary cls;

  const _EventsTab({required this.cls});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView(
      children: [
        const SectionHeader(
          title: 'Events',
          subtitle: 'Upcoming due dates extracted from your syllabus (reminders are sent 24h before).',
        ),
        const SizedBox(height: 14),
        YiriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              if (cls.events.isEmpty)
                const Text(
                  'No events were detected. Try adding lines with dates like “2026-02-15 Exam 1”.',
                  style: TextStyle(color: YiriTheme.mutedText, height: 1.25),
                )
              else
                Column(
                  children: [
                    for (final e in cls.events.take(20)) ...[
                      _EventRow(e: e),
                      const SizedBox(height: 10),
                    ]
                  ],
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  cls.events.where((e) => e.dueAt.isAfter(now)).isEmpty
                      ? 'All detected events are in the past. Re-submit your syllabus if dates were parsed incorrectly.'
                      : 'Reminders are scheduled by the backend at roughly 24 hours before each due date (requires Twilio configured on the server).',
                  style: const TextStyle(color: YiriTheme.mutedText, height: 1.25, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: const TextStyle(color: YiriTheme.mutedText, fontWeight: FontWeight.w800)),
    );
  }
}

class _GradeRow extends StatelessWidget {
  final GradeItem g;

  const _GradeRow({required this.g});

  @override
  Widget build(BuildContext context) {
    final pct = (g.earned / g.possible) * 100;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.eventTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(g.category, style: const TextStyle(color: YiriTheme.mutedText, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text('${g.earned.toStringAsFixed(0)}/${g.possible.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: YiriTheme.yiriRed.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final EventItem e;

  const _EventRow({required this.e});

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatMediumDate(e.dueAt);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: YiriTheme.yiriRed.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.event, color: YiriTheme.yiriRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: YiriTheme.mutedText, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
