import '../models/yiri_models.dart';

class GradeSnapshot {
  final double? current; // 0..100
  final double? projected; // 0..100
  final double? requiredRemainingAverageForGoal; // 0..100

  const GradeSnapshot({
    required this.current,
    required this.projected,
    required this.requiredRemainingAverageForGoal,
  });
}

class GradeCalculator {
  static GradeSnapshot compute({
    required ClassSummary cls,
    required double goalFinalGrade,
  }) {
    final weights = cls.categories;
    if (weights.isEmpty) {
      // No rubric; fall back to simple average of all grades.
      final current = _simpleAverage(cls.grades);
      return GradeSnapshot(
        current: current,
        projected: current,
        requiredRemainingAverageForGoal: null,
      );
    }

    final byCategory = <String, List<GradeItem>>{};
    for (final g in cls.grades) {
      byCategory.putIfAbsent(g.category.toLowerCase(), () => []).add(g);
    }

    double knownWeight = 0;
    double unknownWeight = 0;
    double knownWeighted = 0;

    for (final cw in weights) {
      final w = cw.weight;
      final key = cw.name.toLowerCase();
      final items = byCategory[key] ?? const <GradeItem>[];
      final avg = _categoryAverage(items);

      if (avg == null) {
        unknownWeight += w;
      } else {
        knownWeight += w;
        knownWeighted += avg * w;
      }
    }

    final current = knownWeight > 0 ? (knownWeighted / knownWeight) : null;

    // Projected final: treat unknown categories as "assumed remaining average".
    final projected = (knownWeighted + (cls.assumedRemainingAverage * unknownWeight)) /
        (knownWeight + unknownWeight == 0 ? 1 : (knownWeight + unknownWeight));

    // Goal reverse-calc:
    // (knownWeighted + R*unknownWeight) / totalWeight = goal
    final totalWeight = knownWeight + unknownWeight;
    final required = unknownWeight > 0
        ? ((goalFinalGrade * totalWeight) - knownWeighted) / unknownWeight
        : null;

    return GradeSnapshot(
      current: current?.clamp(0, 100),
      projected: projected.clamp(0, 100),
      requiredRemainingAverageForGoal: required?.clamp(0, 100),
    );
  }

  static double? _categoryAverage(List<GradeItem> items) {
    if (items.isEmpty) return null;
    double earned = 0;
    double possible = 0;
    for (final i in items) {
      earned += i.earned;
      possible += i.possible;
    }
    if (possible <= 0) return null;
    return (earned / possible) * 100;
  }

  static double? _simpleAverage(List<GradeItem> items) {
    if (items.isEmpty) return null;
    double earned = 0;
    double possible = 0;
    for (final i in items) {
      earned += i.earned;
      possible += i.possible;
    }
    if (possible <= 0) return null;
    return (earned / possible) * 100;
  }
}
