import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/budget/budget_response_dto.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/dialogs/budget/add_budget_dialog.dart';
import '../../widgets/dialogs/budget/edit_budget_dialog.dart';
import '../../widgets/dialogs/budget/remove_budget_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';
import 'budget_details_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  _BudgetSort _sort = _BudgetSort.dateDesc;

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
    final budgetsAsync = ref.watch(budgetNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Orcamentos'),
      drawer: const GlobalDrawer(),
      body: TablePageShell(
        title: 'Orcamentos',
        icon: Icons.description_rounded,
        actions: [
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(budgetNotifierProvider.notifier).loadBudgets(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Atualizar'),
          ),
          ElevatedButton.icon(
            onPressed: _showAddBudgetDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo Orcamento'),
          ),
        ],
        filters: _buildFilters(),
        content: budgetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(
              ErrorMessageUtils.fromObject(
                e,
                fallback: 'Erro ao carregar orcamentos.',
              ),
            ),
          ),
          data: (budgets) => _buildTableContent(budgets),
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
          child: DropdownButtonFormField<_BudgetSort>(
            value: _sort,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Ordenar',
              prefixIcon: Icon(Icons.swap_vert_rounded, size: 18),
            ),
            items: _BudgetSort.values
                .map(
                  (value) => DropdownMenuItem<_BudgetSort>(
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
          hintText: 'Pesquisar por entidade, estado ou total',
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

  Widget _buildTableContent(List<BudgetResponseDTO> budgets) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = budgets.where((budget) {
      final matchesSearch = budget.entityName.toLowerCase().contains(query) ||
          budget.state.toLowerCase().contains(query) ||
          budget.total.toString().contains(query) ||
          (budget.referenceCode ?? budget.id).toLowerCase().contains(query);

      final inStartRange =
          _startDate == null || !budget.date.isBefore(_startDate!);
      final inEndRange = _endDate == null || !budget.date.isAfter(_endDate!);
      return matchesSearch && inStartRange && inEndRange;
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _BudgetSort.dateAsc:
          return a.date.compareTo(b.date);
        case _BudgetSort.dateDesc:
          return b.date.compareTo(a.date);
        case _BudgetSort.totalAsc:
          return a.total.compareTo(b.total);
        case _BudgetSort.totalDesc:
          return b.total.compareTo(a.total);
      }
    });

    final totalPages =
        max(1, ((filtered.length + _rowsPerPage - 1) / _rowsPerPage).floor());
    final effectivePage = min(max(_currentPage, 0), totalPages - 1);
    final startIndex = effectivePage * _rowsPerPage;
    final endIndex = min(startIndex + _rowsPerPage, filtered.length);
    final pageBudgets = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <BudgetResponseDTO>[];
    final displayBudgets = List<BudgetResponseDTO?>.generate(
      _rowsPerPage,
      (index) => index < pageBudgets.length ? pageBudgets[index] : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppTableContainer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = max(constraints.maxWidth, 1080.0);
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
                          label: _HeaderCell('Entidade'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Data'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Desconto'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Total'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Estado'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Acoes'),
                        ),
                      ],
                      rows: displayBudgets
                          .map((budget) => _buildRow(budget))
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

  DataRow _buildRow(BudgetResponseDTO? budget) {
    if (budget == null) {
      return const DataRow(
        cells: [
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
        DataCell(_BodyCell(budget.referenceCode ?? budget.id, isPrimary: true)),
        DataCell(_BodyCell(budget.entityName)),
        DataCell(_BodyCell(DateFormat('dd/MM/yyyy').format(budget.date))),
        DataCell(_BodyCell(_currencyFormat.format(budget.discount))),
        DataCell(_BodyCell(_currencyFormat.format(budget.total))),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: _StatusBadge(state: budget.state),
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
                        builder: (_) => BudgetDetailScreen(budgetId: budget.id),
                      ),
                    );
                  },
                ),
                if (budget.state.toUpperCase() == 'PENDENTE') ...[
                  const SizedBox(width: 8),
                  TableActionIconButton(
                    icon: Icons.edit_rounded,
                    color: Colors.lightBlueAccent,
                    tooltip: 'Editar orcamento',
                    onPressed: () => _editBudget(budget),
                  ),
                ],
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Remover orcamento',
                  onPressed: () => _removeBudget(budget),
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

  String _sortLabel(_BudgetSort value) {
    switch (value) {
      case _BudgetSort.dateAsc:
        return 'Data ascendente';
      case _BudgetSort.dateDesc:
        return 'Data descendente';
      case _BudgetSort.totalAsc:
        return 'Total ascendente';
      case _BudgetSort.totalDesc:
        return 'Total descendente';
    }
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddBudgetDialog(
        onBudgetAdded: (newBudget) async {
          await ref
              .read(budgetNotifierProvider.notifier)
              .createBudget(newBudget);
        },
      ),
    );
  }

  void _editBudget(BudgetResponseDTO budget) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditBudgetDialog(
        budget: budget,
        onBudgetUpdated: (updatedBudget) async {
          await ref
              .read(budgetNotifierProvider.notifier)
              .updateBudget(budget.id, updatedBudget);
        },
      ),
    );
  }

  void _removeBudget(BudgetResponseDTO budget) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RemoveBudgetDialog(
        budget: budget,
        onConfirmed: () async {
          await ref
              .read(budgetNotifierProvider.notifier)
              .deleteBudget(budget.id);
        },
      ),
    );
  }
}

enum _BudgetSort {
  dateAsc,
  dateDesc,
  totalAsc,
  totalDesc,
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

class _StatusBadge extends StatelessWidget {
  final String state;

  const _StatusBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final normalized = state.toUpperCase();
    late final Color tone;
    switch (normalized) {
      case 'ACEITE':
        tone = Colors.greenAccent;
        break;
      case 'REJEITADO':
        tone = Colors.redAccent;
        break;
      default:
        tone = Colors.amberAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withOpacity(0.35)),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: tone,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
