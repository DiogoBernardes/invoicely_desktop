import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/product/product_create_dto.dart';
import '../dto/product/product_response_dto.dart';
import '../dto/product/product_update_dto.dart';

class ProductService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<ProductResponseDTO>> getAllProducts() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/commercial-items',
        queryParameters: {'type': 'PRODUTO'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => ProductResponseDTO.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter produtos.',
        ),
      );
    }
  }

  Future<ProductResponseDTO> getProduct(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/commercial-items/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProductResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter produto.',
        ),
      );
    }
  }

  Future<ProductResponseDTO> createProduct(ProductCreateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/commercial-items/create',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProductResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao criar produto.',
        ),
      );
    }
  }

  Future<ProductResponseDTO> updateProduct(
    String id,
    ProductUpdateDTO dto,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/commercial-items/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProductResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar produto.',
        ),
      );
    }
  }

  Future<void> deleteProduct(String id) async {
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
          fallback: 'Erro ao remover produto.',
        ),
      );
    }
  }
}
