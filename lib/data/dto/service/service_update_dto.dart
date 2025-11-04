class ServiceUpdateDTO {
  final String? name;
  final String? description;
  final double? price;
  final String? type;

  const ServiceUpdateDTO({this.name, this.description, this.price, this.type});

  Map<String, dynamic> toJson() => {
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (price != null) "price": price,
      };
}
