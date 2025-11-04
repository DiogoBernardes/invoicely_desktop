import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoicely_desktop/data/dto/service/service_response_dto.dart';
import '../data/repositories/service_repository.dart';
import '../data/services/service_service.dart';
import '../notifiers/service_notifier.dart';

final serviceServiceProvider = Provider((ref) => ServiceService());
final serviceRepositoryProvider =
    Provider((ref) => ServiceRepository(ref.watch(serviceServiceProvider)));

final serviceNotifierProvider = StateNotifierProvider<ServiceNotifier,
    AsyncValue<List<ServiceResponseDTO>>>(
  (ref) => ServiceNotifier(ref.watch(serviceRepositoryProvider)),
);
