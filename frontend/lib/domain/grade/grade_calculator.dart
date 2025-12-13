import '../models/yiri_models.dart';

class GradeSnapshot {
  final double? current; // 0..100
  final double? projected; // 0..100
  final double? requiredRemainingAverageForGoal; // 0..100
  final double? requiredAverageOnRemainingAssignments; // 0..100 (points-based, if available)

  const GradeSnapshot({
    required this.current,
    required this.projected,
    required this.requiredRemainingAverageForGoal,
    required this.requiredAverageOnRemainingAssignments,
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
        requiredAverageOnRemainingAssignments: null,
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

    final requiredOnRemaining = _requiredAverageOnRemainingAssignments(
      cls: cls,
      goalFinalGrade: goalFinalGrade,
    );

    return GradeSnapshot(
      current: current?.clamp(0, 100),
      projected: projected.clamp(0, 100),
      requiredRemainingAverageForGoal: required?.clamp(0, 100),
      requiredAverageOnRemainingAssignments: requiredOnRemaining?.clamp(0, 100),
    );
  }

  /// After scoring `nextEvent` with `scorePercent`, compute the new required
  /// average across the *remaining assignments after that*.
  static double? requiredAverageAfterScoringNext({
    required ClassSummary cls,
    required double goalFinalGrade,
    required EventItem nextEvent,
    required double scorePercent,
  }) {
    final pp = nextEvent.pointsPossible;
    final cat = nextEvent.category;
    if (pp == null || pp <= 0) return null;
    if (cat == null || cat.trim().isEmpty) return null;

    // Create a lightweight "what-if" class snapshot:
    // - add the hypothetical points to grades
    // - remove that event from remaining pool
    final earned = (scorePercent.clamp(0, 100) / 100.0) * pp;
    final tmpGrades = [
      ...cls.grades,
      GradeItem(eventTitle: 'What-if: ${nextEvent.title}', category: cat, earned: earned, possible: pp),
    ];
    final tmpEvents = cls.events.where((e) => !(e.title == nextEvent.title && e.dueAt == nextEvent.dueAt)).toList(growable: false);

    final tmp = ClassSummary(
      id: cls.id,
      className: cls.className,
      categories: cls.categories,
      events: tmpEvents,
      grades: tmpGrades,
      assumedRemainingAverage: cls.assumedRemainingAverage,
    );

    return _requiredAverageOnRemainingAssignments(cls: tmp, goalFinalGrade: goalFinalGrade);
  }

  /// If future events have both `category` and `pointsPossible`, compute the single
  /// uniform % score needed across ALL remaining assignments (points-based) to hit the goal.
  ///
  /// This is more actionable than category-only math: it answers “what % do I need on the rest?”
  static double? _requiredAverageOnRemainingAssignments({
    required ClassSummary cls,
    required double goalFinalGrade,
  }) {
    final weights = cls.categories;
    if (weights.isEmpty) return null;

    final now = DateTime.now();
    final remaining = cls.events
        .where((e) => e.dueAt.isAfter(now))
        .where((e) => e.category != null && e.category!.trim().isNotEmpty)
        .where((e) => (e.pointsPossible ?? 0) > 0)
        .toList(growable: false);
    if (remaining.isEmpty) return null;

    // Group grades by category for current E/P.
    final earnedByCat = <String, double>{};
    final possibleByCat = <String, double>{};
    for (final g in cls.grades) {
      final k = g.category.toLowerCase();
      earnedByCat[k] = (earnedByCat[k] ?? 0) + g.earned;
      possibleByCat[k] = (possibleByCat[k] ?? 0) + g.possible;
    }

    // Remaining possible points by category.
    final remPossibleByCat = <String, double>{};
    for (final e in remaining) {
      final k = e.category!.toLowerCase();
      remPossibleByCat[k] = (remPossibleByCat[k] ?? 0) + (e.pointsPossible ?? 0);
    }

    double totalWeight = 0;
    double A = 0; // constant term
    double B = 0; // coefficient of s

    for (final cw in weights) {
      final w = cw.weight;
      if (w <= 0) continue;
      totalWeight += w;

      final k = cw.name.toLowerCase();
      final Ei = earnedByCat[k] ?? 0;
      final Pi = possibleByCat[k] ?? 0;
      final Ri = remPossibleByCat[k] ?? 0;

      // If we don't know remaining points for this category, fall back to category-level assumption.
      // This keeps the output conservative but still useful.
      if (Ri <= 0) {
        final assumed = cls.assumedRemainingAverage;
        A += w * assumed;
        continue;
      }

      final denom = Pi + Ri;
      if (denom <= 0) {
        // No current points and only remaining points -> category percent becomes s.
        B += w * 1.0;
        continue;
      }

      // finalPercent_i = 100*(Ei/denom) + s*(Ri/denom)
      A += w * (100.0 * (Ei / denom));
      B += w * (Ri / denom);
    }

    if (totalWeight <= 0) return null;
    if (B <= 0) return null;

    final s = ((goalFinalGrade * totalWeight) - A) / B;
    return s;
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
