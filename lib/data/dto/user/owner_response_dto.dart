class OwnerResponseDTO {
  final String id;
  final String username;
  final String email;

  OwnerResponseDTO({
    required this.id,
    required this.username,
    required this.email,
  });

  factory OwnerResponseDTO.fromJson(Map<String, dynamic> json) {
    return OwnerResponseDTO(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}
