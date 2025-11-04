class ServiceCreateDTO {
  final String name;
  final String description;
  final double price;
  final String type;

  const ServiceCreateDTO({
    required this.name,
    required this.description,
    required this.price,
    this.type = "SERVICO",
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "price": price,
        "type": type,
      };
}
