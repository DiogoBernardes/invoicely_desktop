import 'package:flutter/material.dart';
import '../../../data/dto/client/client_response_dto.dart';
import '../custom_dialog.dart';

class RemoveClientDialog extends StatelessWidget {
  final ClientResponseDTO client;
  final VoidCallback onConfirmed;

  const RemoveClientDialog({
    super.key,
    required this.client,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Remover Cliente',
      content: Text(
        'Tem certeza que deseja remover ${client.name}?',
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
