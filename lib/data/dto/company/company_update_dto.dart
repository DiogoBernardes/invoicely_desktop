import 'dart:io';
import 'package:dio/dio.dart';

class CompanyUpdateDTO {
  final String? email;
  final String? phone;
  final String? address;
  final File? logo;
  final File? signature;
  final File? stamp;

  CompanyUpdateDTO({
    this.email,
    this.phone,
    this.address,
    this.logo,
    this.signature,
    this.stamp,
  });

  Future<Map<String, dynamic>> toFormData() async {
    final map = {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (logo != null)
        'logo': await MultipartFile.fromFile(logo!.path, filename: 'logo.png'),
      if (signature != null)
        'signature': await MultipartFile.fromFile(signature!.path,
            filename: 'signature.png'),
      if (stamp != null)
        'stamp':
            await MultipartFile.fromFile(stamp!.path, filename: 'stamp.png'),
    };

    return map;
  }
}
