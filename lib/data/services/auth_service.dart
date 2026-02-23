import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Falha no login. Verifique as suas credenciais.');
      }

      final data = response.data;
      final user = data['user'] ?? {};

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_access_token', data['accessToken'] ?? '');
      await prefs.setString('jwt_refresh_token', data['refreshToken'] ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_id', user['id']?.toString() ?? '');
      await prefs.setString('user_username', user['username'] ?? '');
      await prefs.setBool(
        'has_company',
        user['company'] != null && user['company'] != '',
      );

      return data;
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Nao foi possivel efetuar login.',
        ),
      );
    }
  }

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('jwt_refresh_token');
    if (refreshToken == null) {
      throw Exception('Sessao expirada. Faca login novamente.');
    }

    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final data = response.data;
      if (data == null || data['accessToken'] == null) {
        throw Exception('Nao foi possivel atualizar o token.');
      }

      await prefs.setString('jwt_access_token', data['accessToken']);
      if (data['refreshToken'] != null) {
        await prefs.setString('jwt_refresh_token', data['refreshToken']);
      }
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Nao foi possivel atualizar a sessao.',
        ),
      );
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

  Future<String> requestPasswordChange({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _extractSuccessMessage(
        response.data,
        fallback: 'Codigo de confirmacao enviado para o email.',
      );
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Nao foi possivel enviar o codigo de confirmacao.',
        ),
      );
    }
  }

  Future<String> confirmPasswordChange({
    required String tokenCode,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/auth/change-password/confirm',
        data: {'token': tokenCode},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _extractSuccessMessage(
        response.data,
        fallback: 'Password alterada com sucesso.',
      );
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Nao foi possivel confirmar a alteracao da password.',
        ),
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  String _extractSuccessMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final parts = <String>[
        data['message']?.toString() ?? '',
        data['details']?.toString() ?? '',
        data['nextStep']?.toString() ?? '',
      ].where((text) => text.trim().isNotEmpty).toList();

      if (parts.isNotEmpty) {
        return parts.join('\n');
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return fallback;
  }
}
