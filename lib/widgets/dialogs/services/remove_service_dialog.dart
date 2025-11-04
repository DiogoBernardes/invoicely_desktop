import 'package:flutter/material.dart';
import '../../../data/dto/service/service_response_dto.dart';
import '../custom_dialog.dart';

class RemoveServiceDialog extends StatelessWidget {
  final ServiceResponseDTO service;
  final VoidCallback onConfirmed;

  const RemoveServiceDialog({
    super.key,
    required this.service,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Remover Serviço',
      content: Text(
        'Tem certeza que deseja remover ${service.name}?',
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
