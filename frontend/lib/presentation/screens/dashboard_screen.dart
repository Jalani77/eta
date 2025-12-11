import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grade/grade_calculator.dart';
import '../../state/app_settings.dart';
import '../../state/classes_state.dart';
import '../widgets/progress_ring.dart';
import '../widgets/yiri_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesState = ref.watch(classesProvider);
    final goal = ref.watch(appSettingsProvider).goalFinalGrade;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your classes, current grades, and where you’re headed.',
            style: TextStyle(color: Color(0xFF4B5563)),
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
                  if (classesState.classes.isEmpty) {
                    return const _EmptyCard();
                  }

                  final c = classesState.classes[idx];
                  final snap = GradeCalculator.compute(cls: c, goalFinalGrade: goal);

                  final currentStr = snap.current == null ? '—' : '${snap.current!.toStringAsFixed(1)}%';
                  final projectedStr = '${snap.projected?.toStringAsFixed(1) ?? '—'}%';

                  return YiriCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.className,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
                                  style: const TextStyle(color: Color(0xFF4B5563), height: 1.25),
                                )
                              else
                                Text(
                                  'Goal calc will appear once your rubric has ungraded categories.',
                                  style: const TextStyle(color: Color(0xFF4B5563), height: 1.25),
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
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700)),
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
    return YiriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('No classes yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text(
            'Go to the Syllabus tab to paste a syllabus and generate your class cards.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.25),
          ),
        ],
      ),
    );
  }
}
