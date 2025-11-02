import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/client/client_response_dto.dart';
import '../data/repositories/client_repository.dart';
import '../data/dto/client/client_create_dto.dart';
import '../data/dto/client/client_update_dto.dart';

class ClientNotifier
    extends StateNotifier<AsyncValue<List<ClientResponseDTO>>> {
  final ClientRepository _repository;

  ClientNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      final clients = await _repository.fetchClients();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createClient(ClientCreateDTO dto) async {
    await _repository.createClient(dto);
    await loadClients();
  }

  Future<void> updateClient(String id, ClientUpdateDTO dto) async {
    await _repository.updateClient(id, dto);
    await loadClients();
  }

  Future<void> deleteClient(String id) async {
    await _repository.deleteClient(id);
    await loadClients();
  }
}
