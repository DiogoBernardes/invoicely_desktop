import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/payment_method/payment_method_response_dto.dart';

class PaymentMethodService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<PaymentMethodResponseDto>> getAllPaymentMethods() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/payment-methods',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => PaymentMethodResponseDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter metodos de pagamento.',
        ),
      );
    }
  }
}
