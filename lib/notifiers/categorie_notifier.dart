import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoicely_desktop/data/dto/category/category_response_dto.dart';
import 'package:invoicely_desktop/data/repositories/categorie_repository.dart';

import '../data/dto/category/category_create_dto.dart';
import '../data/dto/category/category_update_dto.dart';

class CategorieNotifier
    extends StateNotifier<AsyncValue<List<CategoryResponseDto>>> {
  final CategorieRepository _repository;

  CategorieNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategory(String id) async {
    try {
      final category = await _repository.fetchCategory(id);
      state = AsyncValue.data([category]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _repository.fetchCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CategoryResponseDto> createCategory(CategoryCreateDTO dto) async {
    state = const AsyncLoading();
    try {
      final created = await _repository.createCategory(dto);
      await loadCategories();
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCategory(String id, CategoryUpdateDto dto) async {
    state = const AsyncLoading();
    await _repository.updateCategory(id, dto);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncLoading();
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}
