import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import 'login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService authService;

  LoginNotifier(this.authService) : super(LoginState());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
          status: LoginStatus.error, errorMessage: 'Preencha todos os campos');
      return;
    }

    state = state.copyWith(status: LoginStatus.loading);

    try {
      final response = await authService.login(email, password);
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        state = state.copyWith(status: LoginStatus.success);
      } else {
        state = state.copyWith(
            status: LoginStatus.error, errorMessage: 'Login falhou!');
      }
    } catch (e) {
      state =
          state.copyWith(status: LoginStatus.error, errorMessage: e.toString());
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final api = AuthService();
  return LoginNotifier(api);
});
