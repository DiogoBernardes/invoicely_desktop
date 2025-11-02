import 'package:flutter/material.dart';

import '../../../data/dto/client/client_response_dto.dart';
import '../custom_dialog.dart';

class EditClientDialog extends StatefulWidget {
  final ClientResponseDTO? client;
  final void Function(ClientResponseDTO) onClientAdded;

  const EditClientDialog({
    super.key,
    this.client,
    required this.onClientAdded,
  });

  @override
  State<EditClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<EditClientDialog> {
  late TextEditingController _nameController;
  late TextEditingController _nifController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _nifController = TextEditingController(text: widget.client?.nif ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.client?.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.client == null ? 'Adicionar Cliente' : 'Editar Cliente',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(_nameController, 'Nome'),
          const SizedBox(height: 12),
          _buildTextField(_nifController, 'NIF'),
          const SizedBox(height: 12),
          _buildTextField(_emailController, 'Email'),
          const SizedBox(height: 12),
          _buildTextField(_phoneController, 'Telefone'),
          const SizedBox(height: 12),
          _buildTextField(_addressController, 'Endereço'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            final newClient = ClientResponseDTO(
              id: widget.client?.id ?? '',
              name: _nameController.text,
              nif: _nifController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              type: 'CLIENTE',
            );
            widget.onClientAdded(newClient);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 26, 38, 51),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.client == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color.fromARGB(255, 26, 38, 51),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
