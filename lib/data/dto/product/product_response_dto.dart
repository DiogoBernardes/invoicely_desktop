import '../company/company_response_dto.dart';

class ProductResponseDTO {
  final String id;
  final String name;
  final String description;
  final double price;
  final double stockQuantity;
  final double minimumStock;
  final bool lowStock;
  final String type;
  final CompanyResponseDTO? company;

  ProductResponseDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.stockQuantity = 0,
    this.minimumStock = 0,
    this.lowStock = false,
    required this.type,
    this.company,
  });

  factory ProductResponseDTO.fromJson(Map<String, dynamic> json) {
    return ProductResponseDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0,
      minimumStock: (json['minimumStock'] as num?)?.toDouble() ?? 0,
      lowStock: json['lowStock'] as bool? ?? false,
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
      'stockQuantity': stockQuantity,
      'minimumStock': minimumStock,
      'lowStock': lowStock,
      'type': type,
      'company': company?.toJson(),
    };
  }
}
