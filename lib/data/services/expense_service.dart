import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/dio_config.dart';
import '../../core/errors/error_message_utils.dart';
import '../dto/expense/expense_create_dto.dart';
import '../dto/expense/expense_response_dto.dart';
import '../dto/expense/expense_update_dto.dart';

class ExpenseService {
  final Dio _dio = DioClient().dio;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_access_token');
  }

  Future<List<ExpenseResponseDto>> getAllExpenses() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/expenses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => ExpenseResponseDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter despesas.',
        ),
      );
    }
  }

  Future<ExpenseResponseDto> getExpense(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/expenses/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ExpenseResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao obter despesa.',
        ),
      );
    }
  }

  Future<ExpenseResponseDto> createExpense(ExpenseCreateDTO dto) async {
    try {
      final token = await _getToken();
      final formData = FormData.fromMap({
        'entityId': dto.entityId,
        'date': _dateFormat.format(dto.date),
        'value': dto.value.toString(),
        'description': dto.description,
        'categoryId': dto.categoryId,
        'paymentMethodId': dto.paymentMethodId,
        if (dto.stockItemId != null) 'stockItemId': dto.stockItemId,
        if (dto.stockQuantity != null)
          'stockQuantity': dto.stockQuantity.toString(),
      });

      if (dto.filePath != null && dto.filePath!.trim().isNotEmpty) {
        final normalizedPath = dto.filePath!.trim();
        final fileName = normalizedPath.split(RegExp(r'[\\/]')).last;
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(normalizedPath, filename: fileName),
          ),
        );
      }

      final response = await _dio.post(
        '/expenses/create',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );
      return ExpenseResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao criar despesa.',
        ),
      );
    }
  }

  Future<ExpenseResponseDto> updateExpense(
    String id,
    ExpenseUpdateDTO dto,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '/expenses/update/$id',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ExpenseResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao atualizar despesa.',
        ),
      );
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '/expenses/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao remover despesa.',
        ),
      );
    }
  }

  Future<File> downloadAttachment(
    String expenseId, {
    String fallbackName = 'expense_attachment',
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/expenses/$expenseId/download-file',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      final bytes = response.data as List<int>?;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('O ficheiro anexado esta vazio.');
      }

      String filename = '$fallbackName.bin';
      final contentDisposition = response.headers['content-disposition']?.first;
      if (contentDisposition != null) {
        final regex = RegExp(r'filename="(.+)"');
        final match = regex.firstMatch(contentDisposition);
        if (match != null && match.groupCount >= 1) {
          filename = _sanitizeFilename(match.group(1)!);
        }
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on DioException catch (e) {
      throw Exception(
        ErrorMessageUtils.fromDio(
          e,
          fallback: 'Erro ao descarregar comprovativo.',
        ),
      );
    }
  }

  Future<void> openAttachment(
    String expenseId, {
    String fallbackName = 'expense_attachment',
  }) async {
    final file =
        await downloadAttachment(expenseId, fallbackName: fallbackName);
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Nao foi possivel abrir o ficheiro anexado.');
    }
  }

  String _sanitizeFilename(String value) {
    final cleaned = value.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    if (cleaned.isEmpty) return 'expense_attachment.bin';
    return cleaned;
  }
}
