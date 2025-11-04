import '../company/company_response_dto.dart';

class ProductResponseDTO {
  final String id;
  final String name;
  final String description;
  final double price;
  final String type;
  final CompanyResponseDTO? company;

  ProductResponseDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    this.company,
  });

  factory ProductResponseDTO.fromJson(Map<String, dynamic> json) {
    return ProductResponseDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      type: json['type'] as String,
      company: json['company'] != null
          ? CompanyResponseDTO.fromJson(json['company'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type,
      'company': company?.toJson(),
    };
  }
}
