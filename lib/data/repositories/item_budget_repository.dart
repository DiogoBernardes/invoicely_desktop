import '../dto/item_budget/item_budget_create_dto.dart';
import '../dto/item_budget/item_budget_response_dto.dart';
import '../services/item_budget_service.dart';

class ItemBudgetRepository {
  final ItemBudgetService _service;

  ItemBudgetRepository(this._service);

  Future<List<ItemBudgetResponseDTO>> fetchItems(String budgetId) =>
      _service.fetchItems(budgetId);

  Future<ItemBudgetResponseDTO> createItem(
          String budgetId, ItemBudgetCreateDTO dto) =>
      _service.createItem(budgetId, dto);

  Future<ItemBudgetResponseDTO> updateItem(
          String itemId, ItemBudgetCreateDTO dto) =>
      _service.updateItem(itemId, dto);

  Future<void> deleteItem(String itemId) => _service.deleteItem(itemId);
}
