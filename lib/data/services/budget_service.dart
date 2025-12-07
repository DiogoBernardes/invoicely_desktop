// budget_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/dio_config.dart';
import '../dto/budget/budget_create_dto.dart';
import '../dto/budget/budget_response_dto.dart';
import '../dto/budget/budget_update_dto.dart';

class BudgetService {
  final Dio _dio = DioClient().dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<BudgetResponseDTO>> getAllBudgets() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/budgets',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => BudgetResponseDTO.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'Erro ao obter budgets: ${e.response?.data ?? e.message}');
    }
  }

  Future<BudgetResponseDTO> getBudget(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/budgets/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return BudgetResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao obter budget: ${e.response?.data ?? e.message}');
    }
  }

  Future<BudgetResponseDTO> createBudget(BudgetCreateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/budgets/create',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return BudgetResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao criar budget: ${e.response?.data ?? e.message}');
    }
  }

  Future<BudgetResponseDTO> updateBudget(String id, BudgetUpdateDTO dto) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/budgets/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return BudgetResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Erro ao atualizar budget: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '/budgets/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          'Erro ao remover budget: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> sendBudgetToClient(String id) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '/budgets/$id/send-to-client',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          'Erro ao enviar budget ao cliente: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> sendBudgetByEmail(String id, String email) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '/budgets/$id/send-pdf-by-email',
        queryParameters: {'accountantEmail': email},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          'Erro ao enviar budget por email: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> downloadBudgetPdf(String budgetId) async {
    try {
      final token = await _getToken();

      final response = await _dio.get(
        '/budgets/$budgetId/download-pdf',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      String filename = "budget.pdf";
      final contentDisposition = response.headers['content-disposition']?.first;
      if (contentDisposition != null) {
        final regex = RegExp(r'filename="(.+)"');
        final match = regex.firstMatch(contentDisposition);
        if (match != null && match.groupCount >= 1) {
          filename = match.group(1)!;
        }
      }

      final fileBytes = response.data as Uint8List;

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar PDF',
        fileName: filename,
      );
      if (result == null) return;
      final file = File(result);
      await file.writeAsBytes(fileBytes);
    } on DioException catch (e) {
      throw Exception("Erro ao baixar PDF: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Erro inesperado ao baixar PDF: $e");
    }
  }
}
