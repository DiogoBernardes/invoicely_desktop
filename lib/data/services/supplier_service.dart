import 'package:dio/dio.dart';
import 'package:invoicely_desktop/data/dto/supplier/supplier_response_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/dio_config.dart';
import '../dto/supplier/supplier_create_dto.dart';
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
        'Erro ao obter fornecedores: ${e.response?.data ?? e.message}',
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
        'Erro ao criar fornecedor: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<SupplierResponseDto> updateSupplier(
      String id, SupplierUpdateDto dto) async {
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
        'Erro ao atualizar fornecedor: ${e.response?.data ?? e.message}',
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
        'Erro ao remover fornecedor: ${e.response?.data ?? e.message}',
      );
    }
  }
}
