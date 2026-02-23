import 'package:flutter/material.dart';
import 'package:invoicely_desktop/data/dto/expense/expense_response_dto.dart';
import '../custom_dialog.dart';

class RemoveExpenseDialog extends StatelessWidget {
  final ExpenseResponseDto expense;
  final VoidCallback onConfirmed;

  const RemoveExpenseDialog({
    super.key,
    required this.expense,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Remover Despesa',
      content: const Text(
        'Tem certeza que deseja remover a despesa?',
        style: TextStyle(color: Colors.white70),
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
