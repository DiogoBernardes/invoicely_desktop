import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/client/client_create_dto.dart';
import '../dto/client/client_response_dto.dart';
import '../dto/client/client_update_dto.dart';

class ClientService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<ClientResponseDTO> getClient(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/entities/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ClientResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter cliente.',
        ),
      );
    }
  }

  Future<List<ClientResponseDTO>> getAllClients() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/entities',
        queryParameters: {'type': 'CLIENTE'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => ClientResponseDTO.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter clientes.',
        ),
      );
    }
  }

  Future<ClientResponseDTO> createClient(ClientCreateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/entities/create',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ClientResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao criar cliente.',
        ),
      );
    }
  }

  Future<ClientResponseDTO> updateClient(String id, ClientUpdateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/entities/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ClientResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar cliente.',
        ),
      );
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '/entities/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao remover cliente.',
        ),
      );
    }
  }
}
