import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/dio_config.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final user = data['user'] ?? {};

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_access_token', data['accessToken'] ?? '');
        await prefs.setString('jwt_refresh_token', data['refreshToken'] ?? '');
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_id', user['id']?.toString() ?? '');
        await prefs.setString('user_username', user['username'] ?? '');
        await prefs.setBool(
            'has_company', user['company'] != null && user['company'] != '');

        return data;
      } else {
        throw Exception('Falha no login. Verifique as suas credenciais.');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Erro ao conectar com o servidor.');
    }
  }

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('jwt_refresh_token');
    if (refreshToken == null) {
      throw Exception("Sessão expirada. Faça login novamente.");
    }

    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });

    final data = response.data;
    if (data == null || data['accessToken'] == null) {
      throw Exception("Não foi possível atualizar o token.");
    }

    await prefs.setString('jwt_access_token', data['accessToken']);
    if (data['refreshToken'] != null) {
      await prefs.setString('jwt_refresh_token', data['refreshToken']);
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('user_id'),
      'email': prefs.getString('user_email'),
      'username': prefs.getString('user_username'),
      'hasCompany': prefs.getBool('has_company') ?? false,
      'accessToken': prefs.getString('jwt_access_token'),
      'refreshToken': prefs.getString('jwt_refresh_token'),
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_access_token');
    await prefs.remove('jwt_refresh_token');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('has_company');
  }
}
