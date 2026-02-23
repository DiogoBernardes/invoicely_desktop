import 'package:dio/dio.dart';

class ErrorMessageUtils {
  static String fromDio(
    DioException e, {
    String fallback = 'Ocorreu um erro ao comunicar com o servidor.',
  }) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'O pedido excedeu o tempo limite. Tente novamente.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Nao foi possivel estabelecer ligacao ao servidor.';
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = _clean(responseData['message']?.toString());
      final hint = _clean(responseData['hint']?.toString());
      if (message != null && hint != null && hint.isNotEmpty) {
        return '$message\n$hint';
      }
      if (message != null && message.isNotEmpty) {
        return message;
      }
      final error = _clean(responseData['error']?.toString());
      if (error != null && error.isNotEmpty) {
        return error;
      }
    } else if (responseData is String && responseData.trim().isNotEmpty) {
      final mapped = fromObject(responseData, fallback: fallback);
      if (mapped.isNotEmpty) return mapped;
    }

    final message = _clean(e.message);
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return fallback;
  }

  static String fromObject(
    Object error, {
    String fallback = 'Ocorreu um erro inesperado.',
  }) {
    final raw = error.toString().trim();
    if (raw.isEmpty) return fallback;

    var message = raw
        .replaceFirst(RegExp(r'^\s*Exception:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^\s*DioException:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^\s*IOException:\s*', caseSensitive: false), '')
        .trim();

    final mapMessage = RegExp(r'message:\s*([^,}]+)', caseSensitive: false)
        .firstMatch(message)
        ?.group(1)
        ?.trim();
    final mapHint = RegExp(r'hint:\s*([^,}]+)', caseSensitive: false)
        .firstMatch(message)
        ?.group(1)
        ?.trim();

    if (mapMessage != null && mapMessage.isNotEmpty) {
      if (mapHint != null && mapHint.isNotEmpty) {
        return _clean('$mapMessage\n$mapHint') ?? fallback;
      }
      return _clean(mapMessage) ?? fallback;
    }

    if (_looksTechnical(message)) {
      return fallback;
    }

    return _clean(message) ?? fallback;
  }

  static String? _clean(String? value) {
    if (value == null) return null;
    final cleaned = value
        .replaceAll('â€', '')
        .replaceAll('Â', '')
        .replaceAll('Ã', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return null;
    return cleaned;
  }

  static bool _looksTechnical(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('socketexception') ||
        normalized.contains('stack trace') ||
        normalized.contains('dioexception') ||
        normalized.contains('ioexception') ||
        normalized.contains('at ');
  }
}
