import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/supplier/supplier_create_dto.dart';
import '../data/dto/supplier/supplier_response_dto.dart';
import '../data/dto/supplier/supplier_update_dto.dart';
import '../data/repositories/supplier_repository.dart';

class SupplierNotifier
    extends StateNotifier<AsyncValue<List<SupplierResponseDto>>> {
  final SupplierRepository _repository;

  SupplierNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    try {
      final suppliers = await _repository.fetchSuppliers();
      state = AsyncValue.data(suppliers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createSupplier(SupplierCreateDto dto) async {
    await _repository.createSupplier(dto);
    await loadSuppliers();
  }

  Future<void> updateSupplier(String id, SupplierUpdateDto dto) async {
    await _repository.updateSupplier(id, dto);
    await loadSuppliers();
  }

  Future<void> deleteSupplier(String id) async {
    await _repository.deleteSupplier(id);
    await loadSuppliers();
  }
}
