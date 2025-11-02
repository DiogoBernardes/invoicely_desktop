import '../dto/client/client_response_dto.dart';
import '../dto/client/client_create_dto.dart';
import '../dto/client/client_update_dto.dart';
import '../services/client_service.dart';

class ClientRepository {
  final ClientService _service;

  ClientRepository(this._service);

  Future<List<ClientResponseDTO>> fetchClients() => _service.getAllClients();
  Future<ClientResponseDTO> createClient(ClientCreateDTO dto) =>
      _service.createClient(dto);
  Future<ClientResponseDTO> updateClient(String id, ClientUpdateDTO dto) =>
      _service.updateClient(id, dto);
  Future<void> deleteClient(String id) => _service.deleteClient(id);
}
