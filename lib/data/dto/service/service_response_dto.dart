import '../company/company_response_dto.dart';

class ServiceResponseDTO {
  final String id;
  final String name;
  final String description;
  final double price;
  final String type;
  final CompanyResponseDTO? company;

  ServiceResponseDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    this.company,
  });

  factory ServiceResponseDTO.fromJson(Map<String, dynamic> json) {
    return ServiceResponseDTO(
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
