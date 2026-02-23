import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/category/category_create_dto.dart';
import '../dto/category/category_response_dto.dart';
import '../dto/category/category_update_dto.dart';

class CategorieService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<CategoryResponseDto>> getAllCategories() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/category',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => CategoryResponseDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter categorias.',
        ),
      );
    }
  }

  Future<CategoryResponseDto> getCategory(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/category/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CategoryResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter categoria.',
        ),
      );
    }
  }

  Future<CategoryResponseDto> createCategory(CategoryCreateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/category/create',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return CategoryResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao criar categoria.',
        ),
      );
    }
  }

  Future<CategoryResponseDto> updateCategory(
    String id,
    CategoryUpdateDto dto,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/category/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return CategoryResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar categoria.',
        ),
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '/category/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao remover categoria.',
        ),
      );
    }
  }
}
