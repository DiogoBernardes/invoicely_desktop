import 'package:invoicely_desktop/data/dto/company/company_response_dto.dart';

class CategoryResponseDto {
  final String id;
  final CompanyResponseDTO? company;
  final String name;
  final String description;

  CategoryResponseDto({
    required this.id,
    required this.company,
    required this.name,
    required this.description,
  });

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) =>
      CategoryResponseDto(
        id: json['id']?.toString() ?? '',
        company: json['company'] is Map<String, dynamic>
            ? CompanyResponseDTO.fromJson(json['company'])
            : null,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );

  factory CategoryResponseDto.empty() {
    return CategoryResponseDto(
      id: '',
      company: null,
      name: '',
      description: '',
    );
  }
}
