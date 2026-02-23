import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/expense/expense_response_dto.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/dialogs/expense/add_expense_category_dialog.dart';
import '../../widgets/dialogs/expense/add_expense_dialog.dart';
import '../../widgets/dialogs/expense/edit_expense_dialog.dart';
import '../../widgets/dialogs/expense/remove_expense_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';
import 'expense_details_screen.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  _ExpenseSort _sort = _ExpenseSort.dateDesc;

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_PT', symbol: 'EUR ');

  @override
  void dispose() {
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Despesas'),
      drawer: const GlobalDrawer(),
      body: TablePageShell(
        title: 'Despesas',
        icon: Icons.receipt_long_rounded,
        actions: [
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(expenseNotifierProvider.notifier).loadExpenses(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Atualizar'),
          ),
          OutlinedButton.icon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.category_rounded, size: 18),
            label: const Text('Nova Categoria'),
          ),
          ElevatedButton.icon(
            onPressed: _showAddExpenseDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nova Despesa'),
          ),
        ],
        filters: _buildFilters(),
        content: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(
              ErrorMessageUtils.fromObject(
                e,
                fallback: 'Erro ao carregar despesas.',
              ),
            ),
          ),
          data: (expenses) => _buildTableContent(expenses),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final trailingFilters = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _DateField(
          label: 'Data inicial',
          controller: _startDateController,
          onTap: () => _pickStartDate(),
          onClear: _startDate == null ? null : _clearStartDate,
        ),
        _DateField(
          label: 'Data final',
          controller: _endDateController,
          onTap: () => _pickEndDate(),
          onClear: _endDate == null ? null : _clearEndDate,
        ),
        SizedBox(
          width: 250,
          child: DropdownButtonFormField<_ExpenseSort>(
            value: _sort,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Ordenar',
              prefixIcon: Icon(Icons.swap_vert_rounded, size: 18),
            ),
            items: _ExpenseSort.values
                .map(
                  (value) => DropdownMenuItem<_ExpenseSort>(
                    value: value,
                    child: Text(_sortLabel(value)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _sort = value;
                _currentPage = 0;
              });
            },
          ),
        ),
      ],
    );

    return Column(
      children: [
        TableSearchField(
          controller: _searchController,
          hintText: 'Pesquisar por descricao, categoria, valor ou referencia',
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _currentPage = 0;
            });
          },
        ),
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerLeft, child: trailingFilters),
      ],
    );
  }

  Widget _buildTableContent(List<ExpenseResponseDto> expenses) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = expenses.where((expense) {
      final matchesSearch = expense.description.toLowerCase().contains(query) ||
          expense.category.name.toLowerCase().contains(query) ||
          expense.paymentMethod.name.toLowerCase().contains(query) ||
          (expense.stockItemName?.toLowerCase().contains(query) ?? false) ||
          expense.value.toString().contains(query) ||
          (expense.referenceCode ?? expense.id).toLowerCase().contains(query);

      final inStartRange =
          _startDate == null || !expense.date.isBefore(_startDate!);
      final inEndRange = _endDate == null || !expense.date.isAfter(_endDate!);
      return matchesSearch && inStartRange && inEndRange;
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _ExpenseSort.dateAsc:
          return a.date.compareTo(b.date);
        case _ExpenseSort.dateDesc:
          return b.date.compareTo(a.date);
        case _ExpenseSort.valueAsc:
          return a.value.compareTo(b.value);
        case _ExpenseSort.valueDesc:
          return b.value.compareTo(a.value);
      }
    });

    final totalPages =
        max(1, ((filtered.length + _rowsPerPage - 1) / _rowsPerPage).floor());
    final effectivePage = min(max(_currentPage, 0), totalPages - 1);
    final startIndex = effectivePage * _rowsPerPage;
    final endIndex = min(startIndex + _rowsPerPage, filtered.length);
    final pageExpenses = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <ExpenseResponseDto>[];
    final displayExpenses = List<ExpenseResponseDto?>.generate(
      _rowsPerPage,
      (index) => index < pageExpenses.length ? pageExpenses[index] : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppTableContainer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = max(constraints.maxWidth, 1120.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: DataTable(
                      headingRowHeight: 56,
                      dataRowMinHeight: 54,
                      dataRowMaxHeight: 64,
                      horizontalMargin: 0,
                      columnSpacing: 0,
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.panelColorSoft.withOpacity(0.95),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.primaryColor.withOpacity(0.15);
                        }
                        return AppTheme.panelColor.withOpacity(0.78);
                      }),
                      columns: const [
                        DataColumn(
                          label: _HeaderCell('N'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Data'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Descricao'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Categoria'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Metodo Pagamento'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Valor'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Stock'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Acoes'),
                        ),
                      ],
                      rows: displayExpenses
                          .map((expense) => _buildRow(expense))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        TablePaginationBar(
          currentPage: effectivePage + 1,
          totalPages: totalPages,
          onPrevious: effectivePage > 0
              ? () => setState(() => _currentPage = effectivePage - 1)
              : null,
          onNext: effectivePage < totalPages - 1
              ? () => setState(() => _currentPage = effectivePage + 1)
              : null,
        ),
      ],
    );
  }

  DataRow _buildRow(ExpenseResponseDto? expense) {
    if (expense == null) {
      return const DataRow(
        cells: [
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
        ],
      );
    }

    return DataRow(
      cells: [
        DataCell(
            _BodyCell(expense.referenceCode ?? expense.id, isPrimary: true)),
        DataCell(_BodyCell(DateFormat('dd/MM/yyyy').format(expense.date))),
        DataCell(_BodyCell(expense.description)),
        DataCell(_BodyCell(expense.category.name)),
        DataCell(_BodyCell(expense.paymentMethod.name)),
        DataCell(_BodyCell(_currencyFormat.format(expense.value))),
        DataCell(
          _BodyCell(
            expense.stockItemName == null
                ? '-'
                : '${expense.stockItemName} (+${(expense.stockQuantity ?? 0).toStringAsFixed(2)})',
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableActionIconButton(
                  icon: Icons.remove_red_eye_outlined,
                  color: Colors.tealAccent,
                  tooltip: 'Ver detalhes',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExpenseDetailScreen(expenseId: expense.id),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.edit_rounded,
                  color: Colors.lightBlueAccent,
                  tooltip: 'Editar despesa',
                  onPressed: () => _editExpense(expense),
                ),
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Remover despesa',
                  onPressed: () => _removeExpense(expense),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    setState(() {
      _startDate = pickedDate;
      _startDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      _currentPage = 0;
    });
  }

  Future<void> _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    setState(() {
      _endDate = pickedDate;
      _endDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      _currentPage = 0;
    });
  }

  void _clearStartDate() {
    setState(() {
      _startDate = null;
      _startDateController.clear();
      _currentPage = 0;
    });
  }

  void _clearEndDate() {
    setState(() {
      _endDate = null;
      _endDateController.clear();
      _currentPage = 0;
    });
  }

  String _sortLabel(_ExpenseSort value) {
    switch (value) {
      case _ExpenseSort.dateAsc:
        return 'Data ascendente';
      case _ExpenseSort.dateDesc:
        return 'Data descendente';
      case _ExpenseSort.valueAsc:
        return 'Valor ascendente';
      case _ExpenseSort.valueDesc:
        return 'Valor descendente';
    }
  }

  void _showAddExpenseDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddExpenseDialog(
        onExpenseAdded: (newExpense) async {
          await ref
              .read(expenseNotifierProvider.notifier)
              .createExpense(newExpense);
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddExpenseCategoryDialog(),
    );
  }

  void _editExpense(ExpenseResponseDto expense) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditExpenseDialog(
        expense: expense,
        onExpenseUpdated: (updatedExpense) async {
          await ref
              .read(expenseNotifierProvider.notifier)
              .updateExpense(expense.id, updatedExpense);
        },
      ),
    );
  }

  Future<void> _removeExpense(ExpenseResponseDto expense) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RemoveExpenseDialog(
        expense: expense,
        onConfirmed: () async {
          await ref
              .read(expenseNotifierProvider.notifier)
              .deleteExpense(expense.id);
        },
      ),
    );
  }
}

enum _ExpenseSort {
  dateAsc,
  dateDesc,
  valueAsc,
  valueDesc,
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 16),
                ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String value;
  final bool isPrimary;

  const _BodyCell(this.value, {this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPrimary
              ? AppTheme.textPrimaryColor
              : AppTheme.textSecondaryColor,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(height: 20),
    );
  }
}
