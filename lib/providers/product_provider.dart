import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/product/product_response_dto.dart';
import '../data/repositories/product_repository.dart';
import '../data/services/product_service.dart';
import '../notifiers/product_notifier.dart';

final productServiceProvider = Provider((ref) => ProductService());
final productRepositoryProvider =
    Provider((ref) => ProductRepository(ref.watch(productServiceProvider)));

final productNotifierProvider = StateNotifierProvider<ProductNotifier,
    AsyncValue<List<ProductResponseDTO>>>(
  (ref) => ProductNotifier(ref.watch(productRepositoryProvider)),
);
