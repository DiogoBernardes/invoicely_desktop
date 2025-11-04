import 'package:flutter/material.dart';
import 'package:invoicely_desktop/data/dto/product/product_response_dto.dart';
import '../custom_dialog.dart';

class EditProductDialog extends StatefulWidget {
  final ProductResponseDTO? product;
  final void Function(ProductResponseDTO) onProductUpdated;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.product == null ? 'Adicionar Produto' : 'Editar Produto',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(_nameController, 'Nome'),
          const SizedBox(height: 12),
          _buildTextField(_descriptionController, 'Descrição'),
          const SizedBox(height: 12),
          _buildTextField(_priceController, 'Preço'),
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
            final newProduct = ProductResponseDTO(
              id: widget.product?.id ?? '',
              name: _nameController.text,
              description: _descriptionController.text,
              price: double.tryParse(_priceController.text) ?? 0.0,
              type: 'PRODUTO',
              company: widget.product?.company,
            );
            widget.onProductUpdated(newProduct);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 36, 54, 71),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.product == null ? 'Adicionar' : 'Salvar'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
