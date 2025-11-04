import '../dto/product/product_create_dto.dart';
import '../dto/product/product_response_dto.dart';
import '../dto/product/product_update_dto.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _product;

  ProductRepository(this._product);

  Future<List<ProductResponseDTO>> fetchProducts() => _product.getAllProducts();
  Future<ProductResponseDTO> fetchProduct(String id) => _product.getProduct(id);
  Future<ProductResponseDTO> createProduct(ProductCreateDTO dto) =>
      _product.createProduct(dto);
  Future<ProductResponseDTO> updateProduct(String id, ProductUpdateDTO dto) =>
      _product.updateProduct(id, dto);
  Future<void> deleteProduct(String id) => _product.deleteProduct(id);
}
