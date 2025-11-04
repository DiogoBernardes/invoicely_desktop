import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/product/product_create_dto.dart';
import '../data/dto/product/product_response_dto.dart';
import '../data/dto/product/product_update_dto.dart';
import '../data/repositories/product_repository.dart';

class ProductNotifier
    extends StateNotifier<AsyncValue<List<ProductResponseDTO>>> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final products = await _repository.fetchProducts();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadProduct(String id) async {
    try {
      final product = await _repository.fetchProduct(id);
      state = AsyncValue.data([product]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProduct(ProductCreateDTO dto) async {
    await _repository.createProduct(dto);
    await loadProducts();
  }

  Future<void> updateProduct(String id, ProductUpdateDTO dto) async {
    await _repository.updateProduct(id, dto);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }
}
