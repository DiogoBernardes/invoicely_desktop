import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dto/item_budget/item_budget_create_dto.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/service_provider.dart';
import '../custom_dialog.dart';

class EditItemBudgetDialog extends ConsumerStatefulWidget {
  final ItemBudgetCreateDTO item;

  const EditItemBudgetDialog({super.key, required this.item});

  @override
  ConsumerState<EditItemBudgetDialog> createState() =>
      _EditItemBudgetDialogState();
}

class _EditItemBudgetDialogState extends ConsumerState<EditItemBudgetDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedItemId;
  String? _selectedItemName;
  double _unitPrice = 0;
  double _quantity = 1;
  double _iva = 0;
  double _totalWithIva = 0;

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.item.itemId;
    _unitPrice = widget.item.unitPrice;
    _quantity = widget.item.quantity;
    _iva = widget.item.iva;
    _totalWithIva = _quantity * _unitPrice * (1 + _iva / 100);
  }

  void _calculateTotal() {
    setState(() {
      _totalWithIva = _quantity * _unitPrice * (1 + _iva / 100);
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color.fromARGB(255, 26, 38, 51),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productNotifierProvider).value ?? [];
    final services = ref.watch(serviceNotifierProvider).value ?? [];

    final productItem = products.where((p) => p.id == _selectedItemId).toList();
    final serviceItem = services.where((s) => s.id == _selectedItemId).toList();

    if (productItem.isNotEmpty) {
      _selectedItemName ??= productItem.first.name;
    } else if (serviceItem.isNotEmpty) {
      _selectedItemName ??= serviceItem.first.name;
    } else {
      throw Exception("Item não encontrado");
    }

    return CustomDialog(
      title: "Editar Item",
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Item: $_selectedItemName",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity.toString(),
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Quantidade"),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  _quantity = double.tryParse(v) ?? 1;
                  _calculateTotal();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _unitPrice.toString(),
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Preço Unitário"),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  _unitPrice = double.tryParse(v) ?? 0;
                  _calculateTotal();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _iva.toString(),
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("IVA (%)"),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  _iva = double.tryParse(v) ?? 0;
                  _calculateTotal();
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Total (IVA incluído): €${_totalWithIva.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final result = ItemBudgetCreateDTO(
                itemId: _selectedItemId!,
                quantity: _quantity,
                unitPrice: _unitPrice,
                iva: _iva,
              );
              Navigator.pop(context, result);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 36, 54, 71),
            foregroundColor: Colors.white,
          ),
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}
