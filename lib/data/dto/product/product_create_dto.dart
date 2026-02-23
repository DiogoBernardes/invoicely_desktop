class ProductCreateDTO {
  final String name;
  final String description;
  final double price;
  final double stockQuantity;
  final double minimumStock;
  final String type;

  const ProductCreateDTO({
    required this.name,
    required this.description,
    required this.price,
    this.stockQuantity = 0,
    this.minimumStock = 0,
    this.type = "PRODUTO",
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "price": price,
        "stockQuantity": stockQuantity,
        "minimumStock": minimumStock,
        "type": type,
      };
}
