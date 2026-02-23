import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/errors/error_message_utils.dart';
import '../../data/dto/budget/budget_response_dto.dart';
import '../../data/dto/expense/expense_response_dto.dart';
import '../../data/dto/product/product_response_dto.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/global_app_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const List<String> _monthLabels = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_PT', symbol: 'EUR ');

  late int _selectedYear;
  int _selectedMonth = 0; // 0 = todos os meses

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetNotifierProvider);
    final expensesAsync = ref.watch(expenseNotifierProvider);
    final productsAsync = ref.watch(productNotifierProvider);

    final budgets = budgetsAsync.value ?? const <BudgetResponseDTO>[];
    final expenses = expensesAsync.value ?? const <ExpenseResponseDto>[];
    final products = productsAsync.value ?? const <ProductResponseDTO>[];
    final lowStockProducts = products.where((p) => p.lowStock).toList();
    final availableYears = _buildAvailableYears(budgets, expenses);

    if (!availableYears.contains(_selectedYear) && availableYears.isNotEmpty) {
      _selectedYear = availableYears.last;
    }

    final budgetError = budgetsAsync.whenOrNull(
      error: (e, st) => ErrorMessageUtils.fromObject(
        e,
        fallback: 'Erro ao carregar orcamentos.',
      ),
    );
    final expenseError = expensesAsync.whenOrNull(
      error: (e, st) => ErrorMessageUtils.fromObject(
        e,
        fallback: 'Erro ao carregar despesas.',
      ),
    );
    final productError = productsAsync.whenOrNull(
      error: (e, st) => ErrorMessageUtils.fromObject(
        e,
        fallback: 'Erro ao carregar produtos.',
      ),
    );
    final isLoading =
        budgetsAsync.isLoading || expensesAsync.isLoading || productsAsync.isLoading;

    final filteredBudgets = budgets
        .where((budget) => _matchesFilter(budget.date))
        .toList(growable: false);
    final filteredExpenses = expenses
        .where((expense) => _matchesFilter(expense.date))
        .toList(growable: false);

    final totalBudget = _sumBudget(filteredBudgets);
    final acceptedBudget = _sumBudget(
      filteredBudgets.where((budget) => budget.state == 'ACEITE'),
    );
    final totalExpenses = _sumExpenses(filteredExpenses);
    final balance = acceptedBudget - totalExpenses;

    final pendingCount =
        filteredBudgets.where((budget) => budget.state == 'PENDENTE').length;
    final rejectedCount =
        filteredBudgets.where((budget) => budget.state == 'REJEITADO').length;

    final monthlyData = _buildMonthlyData(
      budgets: budgets,
      expenses: expenses,
      year: _selectedYear,
    );

    final weeklyData = _selectedMonth == 0
        ? const <_WeeklyBalancePoint>[]
        : _buildWeeklyData(
            budgets: budgets,
            expenses: expenses,
            year: _selectedYear,
            month: _selectedMonth,
          );

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Dashboard'),
      drawer: const GlobalDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (budgetError != null || expenseError != null || productError != null)
              ? _buildErrorState(
                  budgetError: budgetError,
                  expenseError: expenseError,
                  productError: productError,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilters(availableYears),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _KpiCard(
                            title: 'Total Orcado',
                            value: _currencyFormat.format(totalBudget),
                            color: Colors.blue,
                            icon: Icons.receipt_long_rounded,
                          ),
                          _KpiCard(
                            title: 'Receita Aceite',
                            value: _currencyFormat.format(acceptedBudget),
                            color: Colors.green,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                          _KpiCard(
                            title: 'Total Despesas',
                            value: _currencyFormat.format(totalExpenses),
                            color: Colors.orange,
                            icon: Icons.payments_outlined,
                          ),
                          _KpiCard(
                            title: 'Saldo',
                            value: _currencyFormat.format(balance),
                            color: balance >= 0 ? Colors.teal : Colors.red,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          _KpiCard(
                            title: 'Pendentes',
                            value: pendingCount.toString(),
                            color: Colors.amber,
                            icon: Icons.schedule_outlined,
                          ),
                          _KpiCard(
                            title: 'Rejeitados',
                            value: rejectedCount.toString(),
                            color: Colors.pinkAccent,
                            icon: Icons.cancel_outlined,
                          ),
                          _KpiCard(
                            title: 'Stock Critico',
                            value: lowStockProducts.length.toString(),
                            color: Colors.orangeAccent,
                            icon: Icons.warning_amber_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Evolucao Mensal (Aceites vs Despesas)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MonthlyBalanceChart(data: monthlyData),
                      const SizedBox(height: 36),
                      const Text(
                        'Evolucao Semanal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _selectedMonth == 0
                          ? const _MonthHintCard()
                          : _WeeklyBalanceChart(data: weeklyData),
                      const SizedBox(height: 26),
                      _LowStockPanel(items: lowStockProducts),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFilters(List<int> years) {
    final selectedMonthLabel =
        _selectedMonth == 0 ? 'Todos' : _monthLabels[_selectedMonth - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF132E46).withOpacity(0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          const Text('Ano:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                iconEnabledColor: Colors.white,
                items: years
                    .map((year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        ))
                    .toList(),
                onChanged: (year) {
                  if (year == null) return;
                  setState(() => _selectedYear = year);
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          const Text('Mes:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                iconEnabledColor: Colors.white,
                items: [
                  const DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Todos'),
                  ),
                  ...List.generate(
                    12,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(_monthLabels[index]),
                    ),
                  ),
                ],
                onChanged: (month) {
                  if (month == null) return;
                  setState(() => _selectedMonth = month);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Filtro atual: $selectedMonthLabel/$_selectedYear',
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () async {
              await ref.read(budgetNotifierProvider.notifier).loadBudgets();
              await ref.read(expenseNotifierProvider.notifier).loadExpenses();
              await ref.read(productNotifierProvider.notifier).loadProducts();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required String? budgetError,
    required String? expenseError,
    String? productError,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Erro ao carregar dados do dashboard',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          if (budgetError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Orcamentos: $budgetError',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          if (expenseError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Despesas: $expenseError',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          if (productError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Produtos: $productError',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ref.read(budgetNotifierProvider.notifier).loadBudgets();
              await ref.read(expenseNotifierProvider.notifier).loadExpenses();
              await ref.read(productNotifierProvider.notifier).loadProducts();
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  List<int> _buildAvailableYears(
    List<BudgetResponseDTO> budgets,
    List<ExpenseResponseDto> expenses,
  ) {
    final years = <int>{DateTime.now().year};
    for (final budget in budgets) {
      years.add(budget.date.year);
    }
    for (final expense in expenses) {
      years.add(expense.date.year);
    }
    final orderedYears = years.toList()..sort();
    return orderedYears;
  }

  bool _matchesFilter(DateTime date) {
    if (date.year != _selectedYear) return false;
    if (_selectedMonth != 0 && date.month != _selectedMonth) return false;
    return true;
  }

  double _sumBudget(Iterable<BudgetResponseDTO> budgets) {
    return budgets.fold(0, (total, budget) => total + budget.total);
  }

  double _sumExpenses(Iterable<ExpenseResponseDto> expenses) {
    return expenses.fold(0, (total, expense) => total + expense.value);
  }

  List<_MonthlyBalancePoint> _buildMonthlyData({
    required List<BudgetResponseDTO> budgets,
    required List<ExpenseResponseDto> expenses,
    required int year,
  }) {
    return List.generate(12, (index) {
      final month = index + 1;

      final acceptedBudget = budgets.where((budget) {
        return budget.date.year == year &&
            budget.date.month == month &&
            budget.state == 'ACEITE';
      }).fold(0.0, (sum, budget) => sum + budget.total);

      final totalExpenses = expenses
          .where(
            (expense) =>
                expense.date.year == year && expense.date.month == month,
          )
          .fold(0.0, (sum, expense) => sum + expense.value);

      return _MonthlyBalancePoint(
        label: _monthLabels[index],
        revenue: acceptedBudget,
        expenses: totalExpenses,
      );
    });
  }

  List<_WeeklyBalancePoint> _buildWeeklyData({
    required List<BudgetResponseDTO> budgets,
    required List<ExpenseResponseDto> expenses,
    required int year,
    required int month,
  }) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final totalWeeks = ((daysInMonth - 1) ~/ 7) + 1;

    return List.generate(totalWeeks, (index) {
      final week = index + 1;

      final acceptedBudget = budgets.where((budget) {
        return budget.state == 'ACEITE' &&
            budget.date.year == year &&
            budget.date.month == month &&
            _weekOfMonth(budget.date.day) == week;
      }).fold(0.0, (sum, budget) => sum + budget.total);

      final totalExpenses = expenses.where((expense) {
        return expense.date.year == year &&
            expense.date.month == month &&
            _weekOfMonth(expense.date.day) == week;
      }).fold(0.0, (sum, expense) => sum + expense.value);

      return _WeeklyBalancePoint(
        label: 'Sem $week',
        revenue: acceptedBudget,
        expenses: totalExpenses,
      );
    });
  }

  int _weekOfMonth(int day) => ((day - 1) ~/ 7) + 1;
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: max(210, MediaQuery.of(context).size.width * 0.13),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.18),
              color.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBalanceChart extends StatelessWidget {
  final List<_MonthlyBalancePoint> data;

  const _MonthlyBalanceChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: TextStyle(color: Colors.white70),
        ),
        primaryXAxis: const CategoryAxis(
          labelStyle: TextStyle(color: Colors.white70),
        ),
        primaryYAxis: const NumericAxis(
          labelStyle: TextStyle(color: Colors.white70),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_MonthlyBalancePoint, String>>[
          ColumnSeries<_MonthlyBalancePoint, String>(
            name: 'Receita Aceite',
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.revenue,
            color: Colors.green,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          ColumnSeries<_MonthlyBalancePoint, String>(
            name: 'Despesas',
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.expenses,
            color: Colors.orange,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          LineSeries<_MonthlyBalancePoint, String>(
            name: 'Saldo',
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.balance,
            color: Colors.lightBlueAccent,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBalanceChart extends StatelessWidget {
  final List<_WeeklyBalancePoint> data;

  const _WeeklyBalanceChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: TextStyle(color: Colors.white70),
        ),
        primaryXAxis: const CategoryAxis(
          labelStyle: TextStyle(color: Colors.white70),
        ),
        primaryYAxis: const NumericAxis(
          labelStyle: TextStyle(color: Colors.white70),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_WeeklyBalancePoint, String>>[
          ColumnSeries<_WeeklyBalancePoint, String>(
            name: 'Receita Aceite',
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.revenue,
            color: Colors.green,
          ),
          ColumnSeries<_WeeklyBalancePoint, String>(
            name: 'Despesas',
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.expenses,
            color: Colors.orange,
          ),
          LineSeries<_WeeklyBalancePoint, String>(
            name: 'Saldo',
            dataSource: data,
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.balance,
            color: Colors.lightBlueAccent,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class _MonthHintCard extends StatelessWidget {
  const _MonthHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 36, 54, 71),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: const Text(
        'Selecione um mes especifico para visualizar o grafico semanal.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}

class _LowStockPanel extends StatelessWidget {
  final List<ProductResponseDTO> items;

  const _LowStockPanel({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 36, 54, 71),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: const Text(
          'Sem alertas de stock critico no momento.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 36, 54, 71),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alertas de Stock',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(6).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${item.name}: ${item.stockQuantity.toStringAsFixed(2)} / minimo ${item.minimumStock.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _MonthlyBalancePoint {
  final String label;
  final double revenue;
  final double expenses;

  const _MonthlyBalancePoint({
    required this.label,
    required this.revenue,
    required this.expenses,
  });

  double get balance => revenue - expenses;
}

class _WeeklyBalancePoint {
  final String label;
  final double revenue;
  final double expenses;

  const _WeeklyBalancePoint({
    required this.label,
    required this.revenue,
    required this.expenses,
  });

  double get balance => revenue - expenses;
}
