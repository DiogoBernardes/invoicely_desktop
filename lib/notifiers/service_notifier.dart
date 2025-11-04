import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoicely_desktop/data/dto/service/service_response_dto.dart';
import '../data/dto/service/service_create_dto.dart';
import '../data/dto/service/service_update_dto.dart';
import '../data/repositories/service_repository.dart';

class ServiceNotifier
    extends StateNotifier<AsyncValue<List<ServiceResponseDTO>>> {
  final ServiceRepository _repository;

  ServiceNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final services = await _repository.fetchServices();
      state = AsyncValue.data(services);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadService(String id) async {
    try {
      final service = await _repository.fetchService(id);
      state = AsyncValue.data([service]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createService(ServiceCreateDTO dto) async {
    await _repository.createService(dto);
    await loadServices();
  }

  Future<void> updateService(String id, ServiceUpdateDTO dto) async {
    await _repository.updateService(id, dto);
    await loadServices();
  }

  Future<void> deleteService(String id) async {
    await _repository.deleteService(id);
    await loadServices();
  }
}
