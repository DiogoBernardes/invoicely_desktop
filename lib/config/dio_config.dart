import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';
import 'env_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl ?? ''));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('jwt_access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              await AuthService().refreshAccessToken();

              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('jwt_access_token');

              if (newToken != null) {
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';

                final cloneReq = await dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                    responseType: opts.responseType,
                    contentType: opts.contentType,
                    followRedirects: opts.followRedirects,
                    validateStatus: opts.validateStatus,
                    receiveDataWhenStatusError: opts.receiveDataWhenStatusError,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );

                return handler.resolve(cloneReq);
              }
            } catch (_) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_access_token');
              await prefs.remove('jwt_refresh_token');
            }
          }

          handler.next(e);
        },
      ),
    );
  }
}
