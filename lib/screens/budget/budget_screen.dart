import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/dto/budget/budget_response_dto.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/dialogs/budget/add_budget_dialog.dart';
import '../../widgets/dialogs/budget/edit_budget_dialog.dart';
import '../../widgets/dialogs/budget/remove_budget_dialog.dart';
import '../../widgets/global_app_bar.dart';
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
  late final TextEditingController _sortController;

  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';

  // Ordenação
  String _sortField = 'date';
  bool _sortAsc = true;

  DateTime? _startDate;
  DateTime? _endDate;

  final currencyFormat = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

  @override
  void initState() {
    super.initState();
    _sortController = TextEditingController(
        text: '$_sortField-${_sortAsc ? 'Ascendente' : 'Descendente'}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Orçamentos'),
      drawer: const GlobalDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Orçamentos',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddBudgetDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Adicionar Orçamento',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 54, 71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Pesquisa
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por entidade, estado ou total...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color.fromARGB(221, 36, 54, 71),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 200),

                // Data inicial
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Data inicial',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: const Color.fromARGB(221, 36, 54, 71),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          _startDateController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                          _currentPage = 0;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Data final
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Data final',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: const Color.fromARGB(221, 36, 54, 71),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                          _endDateController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                          _currentPage = 0;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Dropdown de ordenação
                SizedBox(
                  width: 200,
                  child: DropdownMenu<String>(
                    controller: _sortController,
                    initialSelection:
                        '$_sortField-${_sortAsc ? 'Ascendente' : 'Descendente'}',
                    enableFilter: false,
                    label: const Text('Ordenar'),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: const Color.fromARGB(221, 36, 54, 71),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                          value: 'date-Ascendente', label: 'Data Ascendente ↑'),
                      DropdownMenuEntry(
                          value: 'date-Descendente',
                          label: 'Data Descendente ↓'),
                      DropdownMenuEntry(
                          value: 'total-Ascendente',
                          label: 'Total Ascendente ↑'),
                      DropdownMenuEntry(
                          value: 'total-Descendente',
                          label: 'Total Descendente ↓'),
                    ],
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        final parts = value.split('-');
                        _sortField = parts[0];
                        _sortAsc = parts[1] == 'Ascendente';
                        _sortController.text = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // TABLE + PAGINATION
            Expanded(
              child: budgetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    Center(child: Text('Erro ao carregar Orçamentos: $e')),
                data: (budgets) {
                  // FILTRO pesquisa + range datas
                  final filtered = budgets.where((b) {
                    final matchesSearch = b.entityName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        b.state
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        b.total.toString().contains(_searchQuery);

                    final inDateRange = (_startDate == null ||
                            b.date.isAfter(_startDate!
                                .subtract(const Duration(days: 1)))) &&
                        (_endDate == null ||
                            b.date.isBefore(
                                _endDate!.add(const Duration(days: 1))));

                    return matchesSearch && inDateRange;
                  }).toList();

                  // ORDENAR
                  filtered.sort((a, b) {
                    int cmp = 0;
                    if (_sortField == 'date') {
                      cmp = a.date.compareTo(b.date);
                    } else if (_sortField == 'total') {
                      cmp = a.total.compareTo(b.total);
                    }
                    return _sortAsc ? cmp : -cmp;
                  });

                  // PAGINAÇÃO
                  final totalPages = (filtered.length / _rowsPerPage).ceil();
                  final startIndex = _currentPage * _rowsPerPage;
                  final endIndex = startIndex + _rowsPerPage;
                  final pageBudgets = filtered.sublist(
                    startIndex,
                    endIndex > filtered.length ? filtered.length : endIndex,
                  );
                  final displayBudgets = List.generate(
                    _rowsPerPage,
                    (index) =>
                        index < pageBudgets.length ? pageBudgets[index] : null,
                  );

                  const cellPadding =
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white70, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DataTable(
                              headingRowHeight: 56,
                              headingRowColor: MaterialStateProperty.all(
                                  const Color.fromARGB(221, 26, 38, 51)),
                              dataRowColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 36, 54, 71)),
                              columnSpacing: 0,
                              horizontalMargin: 0,
                              columns: [
                                for (final label in [
                                  'Entidade',
                                  'Data',
                                  'Desconto',
                                  'Total',
                                  'Estado',
                                  'Ações'
                                ])
                                  DataColumn(
                                    label: Container(
                                      padding: cellPadding,
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              rows: displayBudgets.map((budget) {
                                if (budget == null) {
                                  return DataRow(
                                    cells: List.generate(
                                      6,
                                      (index) => DataCell(Container(
                                        padding: cellPadding,
                                        child: const Text(''),
                                      )),
                                    ),
                                  );
                                }

                                return DataRow(
                                  cells: [
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(budget.entityName,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(budget.date),
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(
                                          currencyFormat
                                              .format(budget.discount),
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(
                                          currencyFormat.format(budget.total),
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(budget.state,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye,
                                              size: 18),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    BudgetDetailScreen(
                                                        budgetId: budget.id),
                                              ),
                                            );
                                          },
                                          color: Colors.green.shade400,
                                        ),
                                        if (budget.state == 'PENDENTE')
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 18),
                                            onPressed: () =>
                                                _editBudget(budget),
                                            color: Colors.blue.shade400,
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18),
                                          onPressed: () =>
                                              _removeBudget(budget),
                                          color: Colors.red.shade400,
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Pagination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Página ${_currentPage + 1} de ${totalPages == 0 ? 1 : totalPages}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: const Icon(Icons.arrow_back_ios, size: 18),
                            color: Colors.white70,
                          ),
                          IconButton(
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
