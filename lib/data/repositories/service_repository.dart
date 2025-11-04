import 'package:invoicely_desktop/data/services/service_service.dart';
import '../dto/service/service_create_dto.dart';
import '../dto/service/service_response_dto.dart';
import '../dto/service/service_update_dto.dart';

class ServiceRepository {
  final ServiceService _service;

  ServiceRepository(this._service);

  Future<List<ServiceResponseDTO>> fetchServices() => _service.getAllServices();
  Future<ServiceResponseDTO> fetchService(String id) => _service.getService(id);
  Future<ServiceResponseDTO> createService(ServiceCreateDTO dto) =>
      _service.createService(dto);
  Future<ServiceResponseDTO> updateService(String id, ServiceUpdateDTO dto) =>
      _service.updateService(id, dto);
  Future<void> deleteService(String id) => _service.deleteService(id);
}
