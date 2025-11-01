import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../widgets/global_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedYear = '2025';
  String selectedMonth = '7';

  @override
  Widget build(BuildContext context) {
    final years = ['2024', '2025', '2026'];
    final months = List.generate(12, (i) => (i + 1).toString());

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Dashboard'),
      drawer: const GlobalDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Totais
            const Row(
              children: [
                Expanded(
                  child: BudgetCard(
                      title: 'Total Budget',
                      amount: '\$120,000',
                      color: Colors.blue),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: BudgetCard(
                      title: 'Accented Budget',
                      amount: '\$80,000',
                      color: Colors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: BudgetCard(
                      title: 'Experience',
                      amount: '\$40,000',
                      color: Colors.orange),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: BudgetCard(
                      title: 'Total Balance',
                      amount: '\$40,000',
                      color: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 80),

            // Filtros de Ano e Mês
            Row(
              children: [
                const Text('Ano: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedYear,
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      iconEnabledColor: Colors.white,
                      items: years
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y),
                              ))
                          .toList(),
                      onChanged: (y) => setState(() => selectedYear = y!),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Text('Mês: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      iconEnabledColor: Colors.white,
                      items: months
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y),
                              ))
                          .toList(),
                      onChanged: (y) => setState(() => selectedMonth = y!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Gráfico Mensal
            const Text('Balanço Mensal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            MonthlyBalanceChart(selectedYear: selectedYear),

            const SizedBox(height: 32),

            // Gráfico Semanal
            const Text('Balanço Semanal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            WeeklyBalanceChart(
                selectedYear: selectedYear, selectedMonth: selectedMonth),
          ],
        ),
      ),
    );
  }
}

// ---- Widgets ----

class BudgetCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const BudgetCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(amount,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class MonthlyBalanceChart extends StatelessWidget {
  final String selectedYear;

  const MonthlyBalanceChart({super.key, required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    // Dados fictícios (podes substituir com API)
    final data =
        List.generate(12, (i) => ChartData('M${i + 1}', (i + 1) * 10000.0));

    return SizedBox(
      height: 250,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(numberFormat: null),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<ChartData, String>>[
          ColumnSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData d, _) => d.label,
            yValueMapper: (ChartData d, _) => d.value,
            color: Colors.blue,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class WeeklyBalanceChart extends StatelessWidget {
  final String selectedYear;
  final String selectedMonth;

  const WeeklyBalanceChart({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    // Dados fictícios (podes substituir com API)
    final data = [
      ChartData('Semana 1', 5000),
      ChartData('Semana 2', 8000),
      ChartData('Semana 3', 7000),
      ChartData('Semana 4', 6000),
    ];

    return SizedBox(
      height: 250,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(numberFormat: null),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<ChartData, String>>[
          ColumnSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData d, _) => d.label,
            yValueMapper: (ChartData d, _) => d.value,
            color: Colors.orange,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}
