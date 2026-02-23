import '../category/category_response_dto.dart';
import '../payment_method/payment_method_response_dto.dart';

class ExpenseResponseDto {
  final String id;
  final String? referenceCode;
  final String entityId;
  final DateTime date;
  final double value;
  final String description;
  final CategoryResponseDto category;
  final PaymentMethodResponseDto paymentMethod;
  final String? stockItemId;
  final String? stockItemName;
  final double? stockQuantity;
  final String? fileUrl;

  ExpenseResponseDto({
    required this.id,
    this.referenceCode,
    required this.entityId,
    required this.date,
    required this.value,
    required this.description,
    required this.category,
    required this.paymentMethod,
    this.stockItemId,
    this.stockItemName,
    this.stockQuantity,
    this.fileUrl,
  });

  CategoryResponseDto get categories => category;
  PaymentMethodResponseDto get paymentMethods => paymentMethod;

  factory ExpenseResponseDto.fromJson(Map<String, dynamic> json) {
    return ExpenseResponseDto(
      id: json['id']?.toString() ?? '',
      referenceCode: json['referenceCode']?.toString(),
      entityId: json['entityId']?.toString() ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime(2000),
      value: json['value'] is num
          ? (json['value'] as num).toDouble()
          : double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      category: json['category'] != null
          ? CategoryResponseDto.fromJson(json['category'])
          : CategoryResponseDto.empty(),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethodResponseDto.fromJson(json['paymentMethod'])
          : json['paymentMethods'] != null
              ? PaymentMethodResponseDto.fromJson(json['paymentMethods'])
              : PaymentMethodResponseDto.empty(),
      stockItemId: json['stockItemId']?.toString(),
      stockItemName: json['stockItemName']?.toString(),
      stockQuantity: json['stockQuantity'] is num
          ? (json['stockQuantity'] as num).toDouble()
          : double.tryParse(json['stockQuantity']?.toString() ?? ''),
      fileUrl: json['fileUrl']?.toString(),
    );
  }
}
