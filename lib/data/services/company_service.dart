import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/company/company_create_dto.dart';
import '../dto/company/company_response_dto.dart';
import '../dto/company/company_update_dto.dart';

class CompanyService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<CompanyResponseDTO?> getCompany() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/company',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is String) {
        return null;
      }
      return CompanyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter dados da empresa.',
        ),
      );
    }
  }

  Future<CompanyResponseDTO> createCompany(CompanyCreateDTO data) async {
    try {
      final token = await _getToken();
      final formData = await data.toFormData();

      final response = await _dio.post(
        '/company/create',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      return CompanyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Ocorreu um erro ao criar a empresa.',
        ),
      );
    } catch (e) {
      throw Exception(
        ErrorMessageUtils.fromObject(
          e,
          fallback: 'Erro inesperado ao criar a empresa.',
        ),
      );
    }
  }

  Future<CompanyResponseDTO> updateCompany(
    String companyId,
    CompanyUpdateDTO data,
  ) async {
    try {
      final token = await _getToken();
      final formData = await data.toFormData();

      final response = await _dio.put(
        '/company/update/$companyId',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      return CompanyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar a empresa.',
        ),
      );
    }
  }
}
