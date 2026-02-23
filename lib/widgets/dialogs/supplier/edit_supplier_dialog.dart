import 'package:flutter/material.dart';

import '../../../core/errors/error_message_utils.dart';
import '../../../data/dto/supplier/supplier_response_dto.dart';
import '../custom_dialog.dart';

class EditSupplierDialog extends StatefulWidget {
  final SupplierResponseDto? supplier;
  final Future<void> Function(SupplierResponseDto) onSupplierEdited;

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

  bool _isSaving = false;
  String? _feedbackMessage;
  bool _feedbackError = false;

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
      title: widget.supplier == null ? 'Adicionar Fornecedor' : 'Editar Fornecedor',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
            _feedbackBox(),
          _buildTextField(_nameController, 'Nome'),
          const SizedBox(height: 12),
          _buildTextField(_nifController, 'NIF'),
          const SizedBox(height: 12),
          _buildTextField(_emailController, 'Email'),
          const SizedBox(height: 12),
          _buildTextField(_phoneController, 'Telefone'),
          const SizedBox(height: 12),
          _buildTextField(_addressController, 'Endereco'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child:
              const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 36, 54, 71),
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.supplier == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final editedSupplier = SupplierResponseDto(
      id: widget.supplier?.id ?? '',
      name: _nameController.text,
      nif: _nifController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      type: 'FORNECEDOR',
    );

    setState(() => _isSaving = true);
    try {
      await widget.onSupplierEdited(editedSupplier);
      if (!mounted) return;
      setState(() {
        _feedbackError = false;
        _feedbackMessage = 'Fornecedor atualizado com sucesso.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackError = true;
        _feedbackMessage = ErrorMessageUtils.fromObject(
          e,
          fallback: 'Erro ao atualizar fornecedor.',
        );
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _feedbackBox() {
    final tone = _feedbackError ? Colors.redAccent : Colors.greenAccent;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withOpacity(0.45)),
      ),
      child: Text(
        _feedbackMessage!,
        style: TextStyle(color: tone, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      enabled: !_isSaving,
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

  @override
  void dispose() {
    _nameController.dispose();
    _nifController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
