import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/yiri_api.dart';
import 'app_settings.dart';

class AuthState {
  final String? token;
  final String? email;
  final bool busy;
  final String? error;

  const AuthState({
    required this.token,
    required this.email,
    required this.busy,
    required this.error,
  });

  const AuthState.signedOut() : this(token: null, email: null, busy: false, error: null);

  AuthState copyWith({String? token, String? email, bool? busy, String? error}) {
    return AuthState(
      token: token ?? this.token,
      email: email ?? this.email,
      busy: busy ?? this.busy,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return AuthController(api: YiriApi(baseUrl: settings.baseUrl));
});

class AuthController extends StateNotifier<AuthState> {
  static const _kToken = 'yiri.jwt';
  static const _kEmail = 'yiri.email';

  final YiriApi api;

  AuthController({required this.api}) : super(const AuthState.signedOut()) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(_kToken);
    final email = sp.getString(_kEmail);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(token: token, email: email);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final res = await api.login(email: email, password: password);
      final token = res['token']?.toString();
      if (token == null || token.isEmpty) throw Exception('Missing token');

      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kToken, token);
      await sp.setString(_kEmail, email);

      state = state.copyWith(token: token, email: email, busy: false, error: null);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final res = await api.register(email: email, password: password);
      final token = res['token']?.toString();
      if (token == null || token.isEmpty) throw Exception('Missing token');

      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kToken, token);
      await sp.setString(_kEmail, email);

      state = state.copyWith(token: token, email: email, busy: false, error: null);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kEmail);
    state = const AuthState.signedOut();
  }
}
