class SupplierResponseDto {
  final String id;
  final String name;
  final String nif;
  final String email;
  final String phone;
  final String address;
  final String type;

  SupplierResponseDto({
    required this.id,
    required this.name,
    required this.nif,
    required this.email,
    required this.phone,
    required this.address,
    required this.type,
  });

  factory SupplierResponseDto.fromJson(Map<String, dynamic> json) {
    return SupplierResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      nif: json['nif'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nif': nif,
      'email': email,
      'phone': phone,
      'address': address,
      'type': type,
    };
  }
}
