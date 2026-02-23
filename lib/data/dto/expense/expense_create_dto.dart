class ExpenseCreateDTO {
  final String entityId;
  final DateTime date;
  final double value;
  final String description;
  final String categoryId;
  final String paymentMethodId;
  final String? stockItemId;
  final double? stockQuantity;
  final String? filePath;

  ExpenseCreateDTO({
    required this.entityId,
    required this.date,
    required this.value,
    required this.description,
    required this.categoryId,
    required this.paymentMethodId,
    this.stockItemId,
    this.stockQuantity,
    this.filePath,
  });
}
