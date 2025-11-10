import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/company/company_response_dto.dart';
import '../data/dto/company/company_update_dto.dart';
import '../data/services/company_service.dart';

class CompanyNotifier extends StateNotifier<AsyncValue<CompanyResponseDTO?>> {
  final CompanyService _service;

  CompanyNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchCompany();
  }

  Future<void> fetchCompany() async {
    try {
      state = const AsyncValue.loading();
      final company = await _service.getCompany();
      state = AsyncValue.data(company);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCompany({
    required String email,
    required String phone,
    required String address,
    File? logoFile,
    File? signatureFile,
    File? stampFile,
  }) async {
    final currentCompany = state.value;
    if (currentCompany == null) {
      throw Exception('Nenhuma empresa encontrada para atualizar.');
    }

    state = const AsyncValue.loading();

    try {
      final logo = logoFile != null
          ? await MultipartFile.fromFile(logoFile.path, filename: 'logo.png')
          : null;

      final signature = signatureFile != null
          ? await MultipartFile.fromFile(signatureFile.path,
              filename: 'signature.png')
          : null;

      final stamp = stampFile != null
          ? await MultipartFile.fromFile(stampFile.path, filename: 'stamp.png')
          : null;

      final updateDto = CompanyUpdateDTO(
        email: email,
        phone: phone,
        address: address,
        logo: logo,
        signature: signature,
        stamp: stamp,
      );

      final updated =
          await _service.updateCompany(currentCompany.id!, updateDto);

      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => fetchCompany();
}
