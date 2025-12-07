import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';
import '../data/models/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(const LoginState());

  Future<void> login(String email, String password,
      {bool rememberMe = false}) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Por favor insira o email e a password.',
      );
      return;
    }

    try {
      state = state.copyWith(status: LoginStatus.loading);

      final data = await _authService.login(email, password);
      final hasCompany = data['user']?['company'] != null;

      final prefs = await SharedPreferences.getInstance();

      if (rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
      } else {
        await prefs.setBool('remember_me', false);
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      state = state.copyWith(
        status: LoginStatus.success,
        hasCompany: hasCompany,
      );
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: message,
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
