import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/client/client_response_dto.dart';
import '../data/services/client_service.dart';
import '../data/repositories/client_repository.dart';
import '../notifiers/client_notifier.dart';

final clientServiceProvider = Provider((ref) => ClientService());
final clientRepositoryProvider =
    Provider((ref) => ClientRepository(ref.watch(clientServiceProvider)));

final clientNotifierProvider =
    StateNotifierProvider<ClientNotifier, AsyncValue<List<ClientResponseDTO>>>(
  (ref) => ClientNotifier(ref.watch(clientRepositoryProvider)),
);
