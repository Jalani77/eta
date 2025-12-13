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

class EventItem {
  final String title;
  final DateTime dueAt;
  final String? category;
  final double? pointsPossible;

  const EventItem({required this.title, required this.dueAt, this.category, this.pointsPossible});
}

class ClassSummary {
  final String id;
  final String className;
  final List<CategoryWeight> categories;
  final List<EventItem> events;
  final List<GradeItem> grades;
  final double assumedRemainingAverage;

  const ClassSummary({
    required this.id,
    required this.className,
    required this.categories,
    required this.events,
    required this.grades,
    required this.assumedRemainingAverage,
  });
}
