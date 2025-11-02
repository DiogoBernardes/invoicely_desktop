import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/supplier/supplier_response_dto.dart';
import '../data/repositories/supplier_repository.dart';
import '../data/services/supplier_service.dart';
import '../notifiers/supplier_notifier.dart';

final supplierServiceProvider = Provider((ref) => SupplierService());
final supplierRepositoryProvider =
    Provider((ref) => SupplierRepository(ref.watch(supplierServiceProvider)));

final supplierNotifierProvider = StateNotifierProvider<SupplierNotifier,
    AsyncValue<List<SupplierResponseDto>>>(
  (ref) => SupplierNotifier(ref.watch(supplierRepositoryProvider)),
);
