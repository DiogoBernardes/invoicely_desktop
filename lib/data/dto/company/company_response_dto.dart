import '../user/owner_response_dto.dart';

class CompanyResponseDTO {
  final String id;
  final String name;
  final String nif;
  final String email;
  final String phone;
  final String address;
  final String? logoUrl;
  final String? signatureUrl;
  final String? stampUrl;
  final OwnerResponseDTO owner;

  CompanyResponseDTO({
    required this.id,
    required this.name,
    required this.nif,
    required this.email,
    required this.phone,
    required this.address,
    this.logoUrl,
    this.signatureUrl,
    this.stampUrl,
    required this.owner,
  });

  factory CompanyResponseDTO.fromJson(Map<String, dynamic> json) {
    return CompanyResponseDTO(
      id: json['id'],
      name: json['name'],
      nif: json['nif'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      logoUrl: json['logoUrl'],
      signatureUrl: json['signatureUrl'],
      stampUrl: json['stampUrl'],
      owner: OwnerResponseDTO.fromJson(json['owner']),
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
      'logoUrl': logoUrl,
      'signatureUrl': signatureUrl,
      'stampUrl': stampUrl,
      'owner': owner.toJson(),
    };
  }
}
