class ProductCreateDTO {
  final String name;
  final String description;
  final double price;
  final String type;

  const ProductCreateDTO({
    required this.name,
    required this.description,
    required this.price,
    this.type = "PRODUTO",
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "price": price,
        "type": type,
      };
}
