import '../item_budget/item_budget_update_dto.dart';

class BudgetUpdateDTO {
  final String entityId;
  final DateTime date;
  final double discount;
  final double total;
  final String state;
  final List<ItemBudgetUpdateDTO> items;
  final List<String> removedItemIds;

  BudgetUpdateDTO({
    required this.entityId,
    required this.date,
    required this.discount,
    required this.total,
    required this.state,
    required this.items,
    required this.removedItemIds,
  });

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'date': date.toIso8601String(),
        'discount': discount,
        'total': total,
        'state': state,
        'items': items.map((e) => e.toJson()).toList(),
        'removedItemIds': removedItemIds,
      };
}
