// budget_response_dto.dart
import '../item_budget/item_budget_response_dto.dart';

class BudgetResponseDTO {
  final String id;
  final String? referenceCode;
  final String entityId;
  final String entityName;
  final DateTime date;
  final double discount;
  final double total;
  final String state;
  final String? pdfUrl;
  final DateTime? pdfGeneratedAt;
  final List<ItemBudgetResponseDTO> items;

  BudgetResponseDTO({
    required this.id,
    this.referenceCode,
    required this.entityId,
    required this.entityName,
    required this.date,
    required this.discount,
    required this.total,
    required this.state,
    this.pdfUrl,
    this.pdfGeneratedAt,
    required this.items,
  });

  factory BudgetResponseDTO.fromJson(Map<String, dynamic> json) =>
      BudgetResponseDTO(
        id: json['id'],
        referenceCode: json['referenceCode']?.toString(),
        entityId: json['entityId'],
        entityName: json['entityName'],
        date: DateTime.parse(json['date']),
        discount: (json['discount'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        state: json['state'],
        pdfUrl: json['pdfUrl'],
        pdfGeneratedAt: json['pdfGeneratedAt'] != null
            ? DateTime.parse(json['pdfGeneratedAt'])
            : null,
        items: (json['items'] as List)
            .map((e) => ItemBudgetResponseDTO.fromJson(e))
            .toList(),
      );
}
