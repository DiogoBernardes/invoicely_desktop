import 'dart:typed_data';
import '../user/owner_response_dto.dart';

class CompanyResponseDTO {
  final String id;
  final String name;
  final String nif;
  final String email;
  final String phone;
  final String address;
  final Uint8List? logo;
  final Uint8List? signature;
  final Uint8List? stamp;
  final OwnerResponseDTO owner;

  CompanyResponseDTO({
    required this.id,
    required this.name,
    required this.nif,
    required this.email,
    required this.phone,
    required this.address,
    this.logo,
    this.signature,
    this.stamp,
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
      logo: json['logo'] != null
          ? Uint8List.fromList(List<int>.from(json['logo']))
          : null,
      signature: json['signature'] != null
          ? Uint8List.fromList(List<int>.from(json['signature']))
          : null,
      stamp: json['stamp'] != null
          ? Uint8List.fromList(List<int>.from(json['stamp']))
          : null,
      owner: OwnerResponseDTO.fromJson(json['owner']),
    );
  }
}
