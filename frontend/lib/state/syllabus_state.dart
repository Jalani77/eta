import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/yiri_api.dart';
import 'app_settings.dart';
import 'auth_state.dart';
import 'classes_state.dart';

class SyllabusState {
  final bool busy;
  final String? error;
  final String? lastResult;

  const SyllabusState({required this.busy, required this.error, required this.lastResult});

  const SyllabusState.initial() : this(busy: false, error: null, lastResult: null);

  SyllabusState copyWith({bool? busy, String? error, String? lastResult}) {
    return SyllabusState(
      busy: busy ?? this.busy,
      error: error,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

final syllabusProvider = StateNotifierProvider<SyllabusController, SyllabusState>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final auth = ref.watch(authProvider);
  return SyllabusController(
    api: YiriApi(baseUrl: settings.baseUrl),
    token: auth.token,
    onRefreshClasses: () => ref.read(classesProvider.notifier).refresh(),
  );
});

class SyllabusController extends StateNotifier<SyllabusState> {
  final YiriApi api;
  final String? token;
  final Future<void> Function() onRefreshClasses;

  SyllabusController({required this.api, required this.token, required this.onRefreshClasses})
      : super(const SyllabusState.initial());

  Future<void> submit({
    required String className,
    required String syllabusText,
    required String phoneNumberE164,
    required double assumedRemainingAverage,
  }) async {
    if (token == null) {
      state = state.copyWith(error: 'Please sign in first (Settings tab).');
      return;
    }

    state = state.copyWith(busy: true, error: null, lastResult: null);
    try {
      final res = await api.submitSyllabus(
        token: token!,
        className: className,
        syllabusText: syllabusText,
        phoneNumberE164: phoneNumberE164.trim().isEmpty ? null : phoneNumberE164.trim(),
        assumedRemainingAverage: assumedRemainingAverage,
      );

      final parse = res['parseSummary'] as Map<String, dynamic>?;
      final reminders = res['reminders'] as Map<String, dynamic>?;

      state = state.copyWith(
        busy: false,
        lastResult:
            'Parsed categories: ${parse?['detectedCategoryCount'] ?? 0}, events: ${parse?['detectedEventCount'] ?? 0}. Reminders scheduled: ${reminders?['scheduled'] ?? 0}.',
      );

      await onRefreshClasses();
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }
}
