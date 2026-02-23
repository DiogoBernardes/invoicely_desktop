import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/service/service_create_dto.dart';
import '../dto/service/service_response_dto.dart';
import '../dto/service/service_update_dto.dart';

class ServiceService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<ServiceResponseDTO>> getAllServices() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/commercial-items',
        queryParameters: {'type': 'SERVICO'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => ServiceResponseDTO.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter servicos.',
        ),
      );
    }
  }

  Future<ServiceResponseDTO> getService(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/commercial-items/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ServiceResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter servico.',
        ),
      );
    }
  }

  Future<ServiceResponseDTO> createService(ServiceCreateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/commercial-items/create',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ServiceResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao criar servico.',
        ),
      );
    }
  }

  Future<ServiceResponseDTO> updateService(
    String id,
    ServiceUpdateDTO dto,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/commercial-items/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ServiceResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar servico.',
        ),
      );
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '/commercial-items/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao remover servico.',
        ),
      );
    }
  }
}
