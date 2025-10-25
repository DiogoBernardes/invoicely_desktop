import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';
import '../data/models/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(const LoginState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: LoginStatus.loading, errorMessage: null);

    try {
      await _authService.login(email, password);

      final userData = await _authService.getUserData();
      final hasCompany = userData['hasCompany'] as bool? ?? false;

      state = state.copyWith(
        status: LoginStatus.success,
        hasCompany: hasCompany,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('jwt_refresh_token');

    if (refreshToken != null) {
      try {
        await _authService.refreshAccessToken();
        final userData = await _authService.getUserData();
        final hasCompany = userData['hasCompany'] as bool? ?? false;

        state = state.copyWith(
          status: LoginStatus.success,
          hasCompany: hasCompany,
        );
      } catch (_) {
        state = state.copyWith(status: LoginStatus.initial);
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(status: LoginStatus.initial, hasCompany: false);
  }
}
