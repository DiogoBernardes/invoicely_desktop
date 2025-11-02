import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/dio_config.dart';
import '../dto/company/company_create_dto.dart';
import '../dto/company/company_update_dto.dart';
import '../dto/company/company_response_dto.dart';

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
        'Erro ao obter empresa: ${e.response?.data ?? e.message}',
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
      if (e.response?.statusCode == 403) {
        throw Exception('Não tens permissão para realizar esta ação.');
      } else if (e.response?.statusCode == 400) {
        final msg =
            e.response?.data?['message'] ?? 'Os dados enviados são inválidos.';
        throw Exception(msg);
      } else {
        throw Exception('Ocorreu um erro ao criar a empresa. Tenta novamente.');
      }
    } catch (_) {
      throw Exception('Erro inesperado. Por favor tenta novamente.');
    }
  }

  Future<CompanyResponseDTO> updateCompany(
      String companyId, CompanyUpdateDTO data) async {
    try {
      final token = await _getToken();
      final formData = await data.toFormData();
      final response = await _dio.put(
        '/company/update/$companyId',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return CompanyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Erro ao atualizar empresa: ${e.response?.data ?? e.message}',
      );
    }
  }
}
