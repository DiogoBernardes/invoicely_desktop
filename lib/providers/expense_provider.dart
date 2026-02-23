import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dto/expense/expense_response_dto.dart';
import '../data/repositories/expense_repository.dart';
import '../data/services/expense_service.dart';
import '../notifiers/expense_notifier.dart';

final expenseServiceProvider = Provider((ref) => ExpenseService());

final expenseRepositoryProvider =
    Provider((ref) => ExpenseRepository(ref.watch(expenseServiceProvider)));

final expenseNotifierProvider = StateNotifierProvider<ExpenseNotifier,
    AsyncValue<List<ExpenseResponseDto>>>(
  (ref) => ExpenseNotifier(ref.watch(expenseRepositoryProvider)),
);

final expenseByIdProvider =
    FutureProvider.family<ExpenseResponseDto, String>((ref, expenseId) async {
  final repository = ref.read(expenseRepositoryProvider);
  return repository.fetchExpense(expenseId);
});
