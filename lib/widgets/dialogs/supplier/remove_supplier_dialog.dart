import 'package:flutter/material.dart';
import '../../../data/dto/supplier/supplier_response_dto.dart';
import '../custom_dialog.dart';

class RemoveSupplierDialog extends StatelessWidget {
  final SupplierResponseDto supplier;
  final VoidCallback onConfirmed;

  const RemoveSupplierDialog({
    super.key,
    required this.supplier,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Remover Fornecedor',
      content: Text(
        'Tem certeza que deseja remover ${supplier.name}?',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Cancelar', style: TextStyle(color: Colors.white70)),
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
      maxWidthFactor: 0.2,
    );
  }
}
