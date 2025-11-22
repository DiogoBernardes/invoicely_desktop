// budget_create_dto.dart

import '../item_budget/item_budget_create_dto.dart';

class BudgetCreateDTO {
  final String entityId;
  final DateTime date;
  final double discount;
  final double total;
  final String state;
  final List<ItemBudgetCreateDTO> items;

  BudgetCreateDTO({
    required this.entityId,
    required this.date,
    required this.discount,
    required this.total,
    required this.state,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'date': date.toIso8601String(),
        'discount': discount,
        'total': total,
        "state": state,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
