import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/yiri_api.dart';
import 'app_settings.dart';
import 'auth_state.dart';

class UserProfile {
  final String id;
  final String email;
  final String? phoneNumberE164;
  final double goalFinalGrade;

  const UserProfile({
    required this.id,
    required this.email,
    required this.phoneNumberE164,
    required this.goalFinalGrade,
  });
}

class UserProfileState {
  final bool busy;
  final String? error;
  final UserProfile? profile;

  const UserProfileState({required this.busy, required this.error, required this.profile});
  const UserProfileState.initial() : this(busy: false, error: null, profile: null);

  UserProfileState copyWith({bool? busy, String? error, UserProfile? profile}) {
    return UserProfileState(
      busy: busy ?? this.busy,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileController, UserProfileState>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final auth = ref.watch(authProvider);
  return UserProfileController(api: YiriApi(baseUrl: settings.baseUrl), token: auth.token);
});

class UserProfileController extends StateNotifier<UserProfileState> {
  final YiriApi api;
  final String? token;

  UserProfileController({required this.api, required this.token}) : super(const UserProfileState.initial()) {
    if (token != null) refresh();
  }

  Future<void> refresh() async {
    if (token == null) return;
    state = state.copyWith(busy: true, error: null);
    try {
      final res = await api.me(token: token!);
      state = state.copyWith(busy: false, profile: _toProfile(res['user']), error: null);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  Future<void> update({String? phoneNumberE164, double? goalFinalGrade}) async {
    if (token == null) return;
    state = state.copyWith(busy: true, error: null);

    try {
      final res = await api.updateMe(
        token: token!,
        phoneNumberE164: phoneNumberE164,
        goalFinalGrade: goalFinalGrade,
      );
      state = state.copyWith(busy: false, profile: _toProfile(res['user']), error: null);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  UserProfile _toProfile(dynamic raw) {
    final m = raw as Map<String, dynamic>;
    return UserProfile(
      id: m['id']?.toString() ?? '',
      email: m['email']?.toString() ?? '',
      phoneNumberE164: m['phoneNumberE164']?.toString(),
      goalFinalGrade: ((m['goalFinalGrade'] as num?)?.toDouble()) ?? 90,
    );
  }
}
