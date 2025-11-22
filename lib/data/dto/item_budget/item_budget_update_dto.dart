class ItemBudgetUpdateDTO {
  final String itemId;
  final double quantity;
  final double unitPrice;
  final double iva;

  ItemBudgetUpdateDTO({
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.iva,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'iva': iva,
      };
}
