import 'package:flutter/material.dart';
import '../../../data/dto/budget/budget_response_dto.dart';
import '../custom_dialog.dart';

class RemoveBudgetDialog extends StatelessWidget {
  final BudgetResponseDTO budget;
  final VoidCallback onConfirmed;

  const RemoveBudgetDialog({
    super.key,
    required this.budget,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Remover Orçamento',
      content: Text(
        'Tem certeza que deseja remover o orçamento ${budget.entityName}?',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirmed();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Remover'),
        ),
      ],
      maxWidthFactor: 0.3,
    );
  }
}
