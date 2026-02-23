import 'package:invoicely_desktop/data/services/supplier_service.dart';
import '../dto/supplier/supplier_create_dto.dart';
import '../dto/supplier/supplier_response_dto.dart';
import '../dto/supplier/supplier_update_dto.dart';

class SupplierRepository {
  final SupplierService _service;

  SupplierRepository(this._service);

  Future<List<SupplierResponseDto>> fetchSuppliers() =>
      _service.getAllSuppliers();
  Future<SupplierResponseDto> fetchSupplier(String id) =>
      _service.getSupplier(id);
  Future<SupplierResponseDto> createSupplier(SupplierCreateDto dto) =>
      _service.createSupplier(dto);
  Future<SupplierResponseDto> updateSupplier(
          String id, SupplierUpdateDto dto) =>
      _service.updateSupplier(id, dto);
  Future<void> deleteSupplier(String id) => _service.deleteSupplier(id);
}
