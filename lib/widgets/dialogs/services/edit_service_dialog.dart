import 'package:flutter/material.dart';
import 'package:invoicely_desktop/data/dto/service/service_response_dto.dart';
import '../custom_dialog.dart';

class EditServiceDialog extends StatefulWidget {
  final ServiceResponseDTO? service;
  final void Function(ServiceResponseDTO) onServiceUpdated;

  const EditServiceDialog({
    super.key,
    this.service,
    required this.onServiceUpdated,
  });

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
    _priceController =
        TextEditingController(text: widget.service?.price.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.service == null ? 'Adicionar Serviço' : 'Editar Serviço',
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
            final newService = ServiceResponseDTO(
              id: widget.service?.id ?? '',
              name: _nameController.text,
              description: _descriptionController.text,
              price:
                  double.tryParse(_priceController.text.replaceAll(',', '.')) ??
                      0.0,
              type: 'SERVICO',
              company: widget.service?.company,
            );
            widget.onServiceUpdated(newService);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 36, 54, 71),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.service == null ? 'Adicionar' : 'Salvar'),
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
