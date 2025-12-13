import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String baseUrl;
  final double goalFinalGrade;

  const AppSettings({
    required this.baseUrl,
    required this.goalFinalGrade,
  });

  AppSettings copyWith({String? baseUrl, double? goalFinalGrade}) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      goalFinalGrade: goalFinalGrade ?? this.goalFinalGrade,
    );
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsController, AppSettings>((ref) {
  return AppSettingsController();
});

class AppSettingsController extends StateNotifier<AppSettings> {
  static const _kBaseUrl = 'yiri.baseUrl';
  static const _kGoal = 'yiri.goalFinal';

  AppSettingsController()
      : super(const AppSettings(
          baseUrl: 'http://localhost:3001',
          goalFinalGrade: 90,
        )) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final baseUrl = sp.getString(_kBaseUrl);
    final goal = sp.getDouble(_kGoal);
    state = state.copyWith(
      baseUrl: baseUrl ?? state.baseUrl,
      goalFinalGrade: goal ?? state.goalFinalGrade,
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
}
