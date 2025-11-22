// budget_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dto/budget/budget_response_dto.dart';
import '../data/repositories/budget_repository.dart';
import '../data/services/budget_service.dart';
import '../notifiers/budget_notifier.dart';

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<List<BudgetResponseDTO>>>(
        (ref) {
  final repository = BudgetRepository(BudgetService());
  return BudgetNotifier(repository);
});
