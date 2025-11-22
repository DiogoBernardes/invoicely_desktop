import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final String budgetId;

  const BudgetDetailScreen({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetNotifierProvider);

    final currencyFormat = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Orçamento')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: budgetsAsync.when(
          data: (budgets) {
            final budget = budgets.firstWhere((b) => b.id == budgetId);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entidade: ${budget.entityName}',
                    style: const TextStyle(fontSize: 20)),
                Text('Data: ${DateFormat('dd/MM/yyyy').format(budget.date)}',
                    style: const TextStyle(fontSize: 20)),
                Text('Desconto: ${currencyFormat.format(budget.discount)}',
                    style: const TextStyle(fontSize: 20)),
                Text('Total: ${currencyFormat.format(budget.total)}',
                    style: const TextStyle(fontSize: 20)),
                Text('Estado: ${budget.state}',
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                const Text('Itens:',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: budget.items.length,
                    itemBuilder: (context, index) {
                      final item = budget.items[index];
                      return ListTile(
                        title: Text(item.itemName),
                        subtitle: Text(
                            'Quantidade: ${item.quantity}, Preço Unitário: ${currencyFormat.format(item.unitPrice)}, IVA: ${item.iva}%'),
                        trailing: Text(
                            'Total: ${currencyFormat.format(item.totalWithIva)}'),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(budgetNotifierProvider.notifier)
                            .sendToClient(budget.id);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Enviado ao cliente com sucesso')));
                      },
                      child: const Text('Enviar ao Cliente'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(budgetNotifierProvider.notifier)
                            .sendByEmail(
                                budget.id, 'Diogobernardes2000@gmail.com');
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Enviado por email com sucesso')));
                      },
                      child: const Text('Enviar por Email'),
                    ),
                  ],
                )
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erro ao carregar budget: $e')),
        ),
      ),
    );
  }
}
