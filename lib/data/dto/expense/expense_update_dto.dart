import 'package:intl/intl.dart';

class ExpenseUpdateDTO {
  final String entityId;
  final DateTime date;
  final double value;
  final String description;
  final String categoryId;
  final String paymentMethodId;
  final String? stockItemId;
  final double? stockQuantity;
  final bool clearStockAdjustment;

  ExpenseUpdateDTO({
    required this.entityId,
    required this.date,
    required this.value,
    required this.description,
    required this.categoryId,
    required this.paymentMethodId,
    this.stockItemId,
    this.stockQuantity,
    this.clearStockAdjustment = false,
  });

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'date': _dateFormat.format(date),
        'value': value,
        'description': description,
        'categoryId': categoryId,
        'paymentMethodId': paymentMethodId,
        if (stockItemId != null) 'stockItemId': stockItemId,
        if (stockQuantity != null) 'stockQuantity': stockQuantity,
        if (clearStockAdjustment) 'clearStockAdjustment': true,
      };
}
