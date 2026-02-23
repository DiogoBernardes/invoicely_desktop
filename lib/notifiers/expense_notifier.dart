import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../data/dto/expense/expense_create_dto.dart';
import '../data/dto/expense/expense_response_dto.dart';
import '../data/dto/expense/expense_update_dto.dart';
import '../data/repositories/expense_repository.dart';

class ExpenseNotifier
    extends StateNotifier<AsyncValue<List<ExpenseResponseDto>>> {
  final ExpenseRepository _repository;

  ExpenseNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpense(String id) async {
    try {
      final expense = await _repository.fetchExpense(id);
      state = AsyncValue.data([expense]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadExpenses() async {
    try {
      final expenses = await _repository.fetchExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createExpense(ExpenseCreateDTO dto) async {
    state = const AsyncLoading();
    try {
      await _repository.createExpense(dto);
      await loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateExpense(String id, ExpenseUpdateDTO dto) async {
    state = const AsyncLoading();
    try {
      await _repository.updateExpense(id, dto);
      await loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteExpense(String id) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<File> downloadAttachment(
    String expenseId, {
    String? fallbackName,
  }) async {
    return _repository.downloadAttachment(
      expenseId,
      fallbackName: fallbackName,
    );
  }

  Future<void> openAttachment(
    String expenseId, {
    String? fallbackName,
  }) async {
    await _repository.openAttachment(
      expenseId,
      fallbackName: fallbackName,
    );
  }
}
