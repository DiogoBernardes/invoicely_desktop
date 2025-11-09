import 'package:flutter/material.dart';
import 'custom_dialog.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirmed;

  const LogoutDialog({
    super.key,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Terminar Sessão',
      content: const Text(
        'Tem a certeza que deseja terminar a sessão?',
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
          child: const Text('Terminar Sessão'),
        ),
      ],
      maxWidthFactor: 0.25,
    );
  }
}
