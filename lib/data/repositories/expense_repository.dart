import 'package:invoicely_desktop/data/dto/expense/expense_response_dto.dart';

import 'dart:io';

import '../dto/expense/expense_create_dto.dart';
import '../dto/expense/expense_update_dto.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _service;

  ExpenseRepository(this._service);

  Future<List<ExpenseResponseDto>> fetchExpenses() => _service.getAllExpenses();
  Future<ExpenseResponseDto> fetchExpense(String id) => _service.getExpense(id);
  Future<ExpenseResponseDto> createExpense(ExpenseCreateDTO dto) =>
      _service.createExpense(dto);
  Future<ExpenseResponseDto> updateExpense(String id, ExpenseUpdateDTO dto) =>
      _service.updateExpense(id, dto);
  Future<void> deleteExpense(String id) => _service.deleteExpense(id);
  Future<File> downloadAttachment(String expenseId, {String? fallbackName}) =>
      _service.downloadAttachment(
        expenseId,
        fallbackName: fallbackName ?? 'expense_attachment',
      );
  Future<void> openAttachment(String expenseId, {String? fallbackName}) =>
      _service.openAttachment(
        expenseId,
        fallbackName: fallbackName ?? 'expense_attachment',
      );
}
