import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/item_budget/item_budget_response_dto.dart';
import '../data/services/item_budget_service.dart';
import '../data/repositories/item_budget_repository.dart';
import '../notifiers/item_budget_notifier.dart';

final itemBudgetServiceProvider = Provider((ref) {
  return ItemBudgetService(
    baseUrl: 'https://api.seusite.com',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer TOKEN'
    },
  );
});

final itemBudgetRepositoryProvider = Provider((ref) {
  return ItemBudgetRepository(ref.watch(itemBudgetServiceProvider));
});

final itemBudgetNotifierProvider = StateNotifierProvider.family<
    ItemBudgetNotifier,
    AsyncValue<List<ItemBudgetResponseDTO>>,
    String>((ref, budgetId) {
  return ItemBudgetNotifier(ref.watch(itemBudgetRepositoryProvider), budgetId);
});
