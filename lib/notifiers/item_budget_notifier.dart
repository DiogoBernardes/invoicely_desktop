import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/item_budget/item_budget_response_dto.dart';
import '../data/dto/item_budget/item_budget_create_dto.dart';
import '../data/repositories/item_budget_repository.dart';

class ItemBudgetNotifier
    extends StateNotifier<AsyncValue<List<ItemBudgetResponseDTO>>> {
  final ItemBudgetRepository _repository;
  final String budgetId;

  ItemBudgetNotifier(this._repository, this.budgetId)
      : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final items = await _repository.fetchItems(budgetId);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createItem(ItemBudgetCreateDTO dto) async {
    await _repository.createItem(budgetId, dto);
    await loadItems();
  }

  Future<void> updateItem(String itemId, ItemBudgetCreateDTO dto) async {
    await _repository.updateItem(itemId, dto);
    await loadItems();
  }

  Future<void> deleteItem(String itemId) async {
    await _repository.deleteItem(itemId);
    await loadItems();
  }
}
