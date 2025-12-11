import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/yiri_api.dart';
import '../domain/models/yiri_models.dart';
import 'app_settings.dart';
import 'auth_state.dart';

class ClassesState {
  final bool busy;
  final String? error;
  final List<ClassSummary> classes;

  const ClassesState({
    required this.busy,
    required this.error,
    required this.classes,
  });

  const ClassesState.initial() : this(busy: false, error: null, classes: const []);

  ClassesState copyWith({bool? busy, String? error, List<ClassSummary>? classes}) {
    return ClassesState(
      busy: busy ?? this.busy,
      error: error,
      classes: classes ?? this.classes,
    );
  }
}

final classesProvider = StateNotifierProvider<ClassesController, ClassesState>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final auth = ref.watch(authProvider);
  return ClassesController(api: YiriApi(baseUrl: settings.baseUrl), token: auth.token);
});

class ClassesController extends StateNotifier<ClassesState> {
  final YiriApi api;
  final String? token;

  ClassesController({required this.api, required this.token}) : super(const ClassesState.initial()) {
    if (token != null) {
      refresh();
    }
  }

  Future<void> refresh() async {
    if (token == null) return;
    state = state.copyWith(busy: true, error: null);

    try {
      final res = await api.listClasses(token: token!);
      final list = (res['classes'] as List<dynamic>? ?? const []).map(_toClass).toList();
      state = state.copyWith(busy: false, classes: list, error: null);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  ClassSummary _toClass(dynamic raw) {
    final m = raw as Map<String, dynamic>;

    final categories = (m['categories'] as List<dynamic>? ?? const [])
        .map((c) {
          final cm = c as Map<String, dynamic>;
          return CategoryWeight(
            name: cm['name']?.toString() ?? 'Category',
            weight: (cm['weight'] as num?)?.toDouble() ?? 0,
          );
        })
        .toList();

    final grades = (m['grades'] as List<dynamic>? ?? const [])
        .map((g) {
          final gm = g as Map<String, dynamic>;
          return GradeItem(
            eventTitle: gm['eventTitle']?.toString() ?? 'Item',
            category: gm['category']?.toString() ?? 'Other',
            earned: (gm['scoreEarned'] as num?)?.toDouble() ?? 0,
            possible: (gm['scorePossible'] as num?)?.toDouble() ?? 1,
          );
        })
        .toList();

    return ClassSummary(
      id: m['id']?.toString() ?? '',
      className: m['className']?.toString() ?? 'Class',
      categories: categories,
      grades: grades,
      assumedRemainingAverage: ((m['assumedRemainingAverage'] as num?)?.toDouble()) ?? 85,
    );
  }
}
