class CategoryWeight {
  final String name;
  final double weight; // 0..100

  const CategoryWeight({required this.name, required this.weight});
}

class GradeItem {
  final String eventTitle;
  final String category;
  final double earned;
  final double possible;

  const GradeItem({
    required this.eventTitle,
    required this.category,
    required this.earned,
    required this.possible,
  });
}

class ClassSummary {
  final String id;
  final String className;
  final List<CategoryWeight> categories;
  final List<GradeItem> grades;
  final double assumedRemainingAverage;

  const ClassSummary({
    required this.id,
    required this.className,
    required this.categories,
    required this.grades,
    required this.assumedRemainingAverage,
  });
}
