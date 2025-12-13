import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grade/grade_calculator.dart';
import '../../state/app_settings.dart';
import '../../state/auth_state.dart';
import '../../state/classes_state.dart';
import '../../state/tab_state.dart';
import '../widgets/progress_ring.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/section_header.dart';
import '../widgets/yiri_card.dart';
import '../theme/yiri_theme.dart';
import 'class_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesState = ref.watch(classesProvider);
    final goal = ref.watch(appSettingsProvider).goalFinalGrade;
    final auth = ref.watch(authProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Dashboard',
            subtitle: 'Your classes, current grades, and where you’re headed.',
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(classesProvider.notifier).refresh(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: classesState.classes.isEmpty ? 1 : classesState.classes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, idx) {
                  if (auth.token == null) {
                    return EmptyStateCard(
                      icon: Icons.lock_outline,
                      title: 'Sign in to sync your classes',
                      message: 'Create an account in Settings to pull your dashboard data from the backend.',
                      ctaLabel: 'Go to Settings',
                      onCta: () => ref.read(tabIndexProvider.notifier).state = 2,
                    );
                  }

                  if (classesState.classes.isEmpty) {
                    return const _EmptyCard();
                  }

                  final c = classesState.classes[idx];
                  final snap = GradeCalculator.compute(cls: c, goalFinalGrade: goal);

                  final currentStr = snap.current == null ? '—' : '${snap.current!.toStringAsFixed(1)}%';
                  final projectedStr = '${snap.projected?.toStringAsFixed(1) ?? '—'}%';

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(\n                      MaterialPageRoute(builder: (_) => ClassDetailScreen(classId: c.id)),\n                    ),
                    child: YiriCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.className,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _Metric(label: 'Current', value: currentStr),
                                    const SizedBox(width: 16),
                                    _Metric(label: 'Projected', value: projectedStr),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (snap.requiredRemainingAverageForGoal != null)
                                  Text(
                                    'To hit ${goal.toStringAsFixed(0)}%, you need ~${snap.requiredRemainingAverageForGoal!.toStringAsFixed(1)}% average on remaining categories.',
                                    style: const TextStyle(color: YiriTheme.mutedText, height: 1.25),
                                  )
                                else
                                  Text(
                                    'Goal calc will appear once your rubric has ungraded categories.',
                                    style: const TextStyle(color: YiriTheme.mutedText, height: 1.25),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          ProgressRing(
                            value: (snap.projected ?? 0) / 100,
                            centerText: (snap.projected ?? 0).toStringAsFixed(0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (classesState.busy) const LinearProgressIndicator(minHeight: 3),
          if (classesState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(classesState.error!, style: const TextStyle(color: Color(0xFFB91C1C))),
            ),
        ],
      ),
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
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateCard(
      icon: Icons.school_outlined,
      title: 'No classes yet',
      message: 'Go to the Syllabus tab to paste a syllabus and generate your class cards.',
    );
  }
}
