import 'dart:io';
import 'package:dio/dio.dart';

class CompanyCreateDTO {
  final String name;
  final String nif;
  final String email;
  final String phone;
  final String address;
  final File? logo;
  final File? signature;
  final File? stamp;

  CompanyCreateDTO({
    required this.name,
    required this.nif,
    required this.email,
    required this.phone,
    required this.address,
    this.logo,
    this.signature,
    this.stamp,
  });

  /// Converte para FormData pronto para envio
  Future<FormData> toFormData() async {
    final formMap = <String, dynamic>{
      'name': name,
      'nif': nif,
      'email': email,
      'phone': phone,
      'address': address,
      if (logo != null)
        'logo': await MultipartFile.fromFile(logo!.path, filename: 'logo.png'),
      if (signature != null)
        'signature': await MultipartFile.fromFile(signature!.path,
            filename: 'signature.png'),
      if (stamp != null)
        'stamp':
            await MultipartFile.fromFile(stamp!.path, filename: 'stamp.png'),
    };

    return FormData.fromMap(formMap);
  }
}
