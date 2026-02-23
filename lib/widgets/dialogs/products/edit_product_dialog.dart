import 'package:flutter/material.dart';
import 'package:invoicely_desktop/data/dto/product/product_response_dto.dart';

import '../../../core/errors/error_message_utils.dart';
import '../custom_dialog.dart';

class EditProductDialog extends StatefulWidget {
  final ProductResponseDTO? product;
  final Future<void> Function(ProductResponseDTO) onProductUpdated;

  const EditProductDialog({
    super.key,
    this.product,
    required this.onProductUpdated,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minimumStockController;

  bool _isSaving = false;
  String? _feedbackMessage;
  bool _feedbackError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(
      text: (widget.product?.stockQuantity ?? 0).toString(),
    );
    _minimumStockController = TextEditingController(
      text: (widget.product?.minimumStock ?? 0).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.product == null ? 'Adicionar Produto' : 'Editar Produto',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
            _feedbackBox(),
          _buildTextField(_nameController, 'Nome'),
          const SizedBox(height: 12),
          _buildTextField(_descriptionController, 'Descricao'),
          const SizedBox(height: 12),
          _buildTextField(_priceController, 'Preco'),
          const SizedBox(height: 12),
          _buildTextField(_stockController, 'Stock Atual'),
          const SizedBox(height: 12),
          _buildTextField(_minimumStockController, 'Stock Minimo'),
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
              : Text(widget.product == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final updatedProduct = ProductResponseDTO(
      id: widget.product?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      stockQuantity:
          double.tryParse(_stockController.text.replaceAll(',', '.')) ?? 0.0,
      minimumStock:
          double.tryParse(_minimumStockController.text.replaceAll(',', '.')) ??
              0.0,
      lowStock: false,
      type: 'PRODUTO',
      company: widget.product?.company,
    );

    setState(() => _isSaving = true);
    try {
      await widget.onProductUpdated(updatedProduct);
      if (!mounted) return;
      setState(() {
        _feedbackError = false;
        _feedbackMessage = 'Produto atualizado com sucesso.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackError = true;
        _feedbackMessage = ErrorMessageUtils.fromObject(
          e,
          fallback: 'Erro ao atualizar produto.',
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
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }
}
