class ProductUpdateDTO {
  final String? name;
  final String? description;
  final double? price;
  final double? stockQuantity;
  final double? minimumStock;
  final String? type;

  const ProductUpdateDTO({
    this.name,
    this.description,
    this.price,
    this.stockQuantity,
    this.minimumStock,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (price != null) "price": price,
        if (stockQuantity != null) "stockQuantity": stockQuantity,
        if (minimumStock != null) "minimumStock": minimumStock,
      };
}
