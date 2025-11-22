class ItemBudgetResponseDTO {
  final String id;
  final String budgetId;
  final String itemId;
  final String itemName;
  double quantity;
  double unitPrice;
  double iva;
  final double totalWithIva;

  ItemBudgetResponseDTO({
    required this.id,
    required this.budgetId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.iva,
    required this.totalWithIva,
  });

  factory ItemBudgetResponseDTO.fromJson(Map<String, dynamic> json) =>
      ItemBudgetResponseDTO(
        id: json['id'],
        budgetId: json['budgetId'],
        itemId: json['itemId'],
        itemName: json['itemName'],
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        iva: (json['iva'] as num).toDouble(),
        totalWithIva: (json['totalWithIva'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'budgetId': budgetId,
        'itemId': itemId,
        'itemName': itemName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'iva': iva,
        'totalWithIva': totalWithIva,
      };
}
