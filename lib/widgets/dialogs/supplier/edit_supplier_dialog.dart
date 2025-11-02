import 'package:flutter/material.dart';
import 'package:invoicely_desktop/data/dto/supplier/supplier_response_dto.dart';
import '../custom_dialog.dart';

class EditSupplierDialog extends StatefulWidget {
  final SupplierResponseDto? supplier;
  final void Function(SupplierResponseDto) onSupplierEdited;

  const EditSupplierDialog({
    super.key,
    this.supplier,
    required this.onSupplierEdited,
  });

  @override
  State<EditSupplierDialog> createState() => _EditSupplierDialogState();
}

class _EditSupplierDialogState extends State<EditSupplierDialog> {
  late TextEditingController _nameController;
  late TextEditingController _nifController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _nifController = TextEditingController(text: widget.supplier?.nif ?? '');
    _emailController =
        TextEditingController(text: widget.supplier?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.supplier?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.supplier?.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.supplier == null
          ? 'Adicionar Fornecedor'
          : 'Editar Fornecedor',
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
            final newSupplier = SupplierResponseDto(
              id: widget.supplier?.id ?? '',
              name: _nameController.text,
              nif: _nifController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              type: 'FORNECEDOR',
            );
            widget.onSupplierEdited(newSupplier);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 26, 38, 51),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.supplier == null ? 'Adicionar' : 'Salvar'),
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
