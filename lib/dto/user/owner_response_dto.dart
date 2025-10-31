class OwnerResponseDTO {
  final String id;
  final String name;
  final String email;

  OwnerResponseDTO({
    required this.id,
    required this.name,
    required this.email,
  });

  factory OwnerResponseDTO.fromJson(Map<String, dynamic> json) {
    return OwnerResponseDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
