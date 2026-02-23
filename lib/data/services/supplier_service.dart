import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/supplier/supplier_create_dto.dart';
import '../dto/supplier/supplier_response_dto.dart';
import '../dto/supplier/supplier_update_dto.dart';

class SupplierService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<SupplierResponseDto>> getAllSuppliers() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/entities',
        queryParameters: {'type': 'FORNECEDOR'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => SupplierResponseDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter fornecedores.',
        ),
      );
    }
  }

  Future<SupplierResponseDto> getSupplier(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/entities/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return SupplierResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter fornecedor.',
        ),
      );
    }
  }

  Future<SupplierResponseDto> createSupplier(SupplierCreateDto dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/entities/create',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return SupplierResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao criar fornecedor.',
        ),
      );
    }
  }

  Future<SupplierResponseDto> updateSupplier(
    String id,
    SupplierUpdateDto dto,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/entities/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return SupplierResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar fornecedor.',
        ),
      );
    }
  }

  Future<void> deleteSupplier(String id) async {
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
          fallback: 'Erro ao remover fornecedor.',
        ),
      );
    }
  }
}
