import 'package:dio/dio.dart';
import '../../config/dio_config.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Response> login(String email, String password) async {
    return _dio
        .post('/auth/login', data: {'email': email, 'password': password});
  }
}
