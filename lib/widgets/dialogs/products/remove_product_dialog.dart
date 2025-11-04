import 'package:flutter/material.dart';
import '../../../data/dto/product/product_response_dto.dart';
import '../custom_dialog.dart';

class RemoveProductDialog extends StatelessWidget {
  final ProductResponseDTO product;
  final VoidCallback onConfirmed;

  const RemoveProductDialog({
    super.key,
    required this.product,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Remover Produto',
      content: Text(
        'Tem certeza que deseja remover ${product.name}?',
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
