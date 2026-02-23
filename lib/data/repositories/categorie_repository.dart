import '../dto/category/category_create_dto.dart';
import '../dto/category/category_response_dto.dart';
import '../dto/category/category_update_dto.dart';
import '../services/categorie_service.dart';

class CategorieRepository {
  final CategorieService _service;

  CategorieRepository(this._service);

  Future<List<CategoryResponseDto>> fetchCategories() =>
      _service.getAllCategories();
  Future<CategoryResponseDto> fetchCategory(String id) =>
      _service.getCategory(id);
  Future<CategoryResponseDto> createCategory(CategoryCreateDTO dto) =>
      _service.createCategory(dto);
  Future<CategoryResponseDto> updateCategory(
          String id, CategoryUpdateDto dto) =>
      _service.updateCategory(id, dto);
  Future<void> deleteCategory(String id) => _service.deleteCategory(id);
}
