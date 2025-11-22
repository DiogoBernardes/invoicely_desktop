import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dto/budget/budget_create_dto.dart';
import '../data/dto/budget/budget_response_dto.dart';
import '../data/dto/budget/budget_update_dto.dart';
import '../data/repositories/budget_repository.dart';

class BudgetNotifier
    extends StateNotifier<AsyncValue<List<BudgetResponseDTO>>> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      final budgets = await _repository.fetchBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBudget(BudgetCreateDTO dto) async {
    await _repository.createBudget(dto);
    await loadBudgets();
  }

  Future<void> updateBudget(String id, BudgetUpdateDTO dto) async {
    await _repository.updateBudget(id, dto);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await loadBudgets();
  }

  Future<void> sendToClient(String id) async {
    await _repository.sendBudgetToClient(id);
  }

  Future<void> sendByEmail(String id, String email) async {
    await _repository.sendBudgetByEmail(id, email);
  }
}
