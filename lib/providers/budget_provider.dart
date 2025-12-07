// budget_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dto/budget/budget_response_dto.dart';
import '../data/repositories/budget_repository.dart';
import '../data/services/budget_service.dart';
import '../notifiers/budget_notifier.dart';

final budgetServiceProvider = Provider((ref) => BudgetService());

final budgetRepositoryProvider =
    Provider((ref) => BudgetRepository(ref.watch(budgetServiceProvider)));

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<List<BudgetResponseDTO>>>(
  (ref) => BudgetNotifier(ref.watch(budgetRepositoryProvider)),
);
