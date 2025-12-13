import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String baseUrl;
  final double goalFinalGrade;
  final double aCutoff;
  final double bCutoff;
  final double cCutoff;

  const AppSettings({
    required this.baseUrl,
    required this.goalFinalGrade,
    required this.aCutoff,
    required this.bCutoff,
    required this.cCutoff,
  });

  AppSettings copyWith({
    String? baseUrl,
    double? goalFinalGrade,
    double? aCutoff,
    double? bCutoff,
    double? cCutoff,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      goalFinalGrade: goalFinalGrade ?? this.goalFinalGrade,
      aCutoff: aCutoff ?? this.aCutoff,
      bCutoff: bCutoff ?? this.bCutoff,
      cCutoff: cCutoff ?? this.cCutoff,
    );
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsController, AppSettings>((ref) {
  return AppSettingsController();
});

class AppSettingsController extends StateNotifier<AppSettings> {
  static const _kBaseUrl = 'yiri.baseUrl';
  static const _kGoal = 'yiri.goalFinal';
  static const _kA = 'yiri.cutoffA';
  static const _kB = 'yiri.cutoffB';
  static const _kC = 'yiri.cutoffC';

  AppSettingsController()
      : super(const AppSettings(
          baseUrl: 'http://localhost:3001',
          goalFinalGrade: 90,
          aCutoff: 90,
          bCutoff: 80,
          cCutoff: 70,
        )) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final baseUrl = sp.getString(_kBaseUrl);
    final goal = sp.getDouble(_kGoal);
    final a = sp.getDouble(_kA);
    final b = sp.getDouble(_kB);
    final c = sp.getDouble(_kC);
    state = state.copyWith(
      baseUrl: baseUrl ?? state.baseUrl,
      goalFinalGrade: goal ?? state.goalFinalGrade,
      aCutoff: a ?? state.aCutoff,
      bCutoff: b ?? state.bCutoff,
      cCutoff: c ?? state.cCutoff,
    );
  }

  Future<void> setBaseUrl(String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kBaseUrl, value);
    state = state.copyWith(baseUrl: value);
  }

  Future<void> setGoalFinalGrade(double value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kGoal, value);
    state = state.copyWith(goalFinalGrade: value);
  }

  Future<void> setLetterCutoffs({double? a, double? b, double? c}) async {
    final sp = await SharedPreferences.getInstance();
    if (a != null) await sp.setDouble(_kA, a);
    if (b != null) await sp.setDouble(_kB, b);
    if (c != null) await sp.setDouble(_kC, c);
    state = state.copyWith(aCutoff: a, bCutoff: b, cCutoff: c);
  }

  Future<void> setGoalFromLetter(String letter) async {
    final l = letter.trim().toUpperCase();
    final v = switch (l) {
      'A' => state.aCutoff,
      'B' => state.bCutoff,
      'C' => state.cCutoff,
      _ => state.goalFinalGrade,
    };
    await setGoalFinalGrade(v);
  }
}
