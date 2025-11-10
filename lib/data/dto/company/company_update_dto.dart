import 'package:dio/dio.dart';

class CompanyUpdateDTO {
  final String? email;
  final String? phone;
  final String? address;
  final MultipartFile? logo;
  final MultipartFile? signature;
  final MultipartFile? stamp;

  CompanyUpdateDTO({
    this.email,
    this.phone,
    this.address,
    this.logo,
    this.signature,
    this.stamp,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (logo != null) 'logo': logo,
      if (signature != null) 'signature': signature,
      if (stamp != null) 'stamp': stamp,
    });
  }
}
