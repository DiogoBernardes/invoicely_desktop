class PaymentMethodResponseDto {
  final String id;
  final String name;
  final String description;

  PaymentMethodResponseDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PaymentMethodResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponseDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  factory PaymentMethodResponseDto.empty() {
    return PaymentMethodResponseDto(
      id: '',
      name: '',
      description: '',
    );
  }
}
