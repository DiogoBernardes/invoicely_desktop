import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dto/item_budget/item_budget_create_dto.dart';
import '../../../data/dto/product/product_response_dto.dart';
import '../../../data/dto/service/service_response_dto.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/service_provider.dart';
import '../custom_dialog.dart';

class AddItemDialog extends ConsumerStatefulWidget {
  final ItemBudgetCreateDTO? item;
  final List<String> excludedItemIds;

  const AddItemDialog({
    super.key,
    this.item,
    this.excludedItemIds = const [],
  });

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

// Wrapper para produtos e serviços
class ItemWrapper {
  final String id;
  final String name;
  final double price;
  final String type;
  final ProductResponseDTO? product;
  final ServiceResponseDTO? service;

  ItemWrapper.product(this.product)
      : id = product!.id,
        name = product.name,
        price = product.price,
        type = "Produto",
        service = null;

  ItemWrapper.service(this.service)
      : id = service!.id,
        name = service.name,
        price = service.price,
        type = "Serviço",
        product = null;

  @override
  bool operator ==(other) =>
      other is ItemWrapper && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => "$name ($type - €$price)";
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();

  ItemWrapper? _selectedItem;
  String _searchQuery = "";

  double _unitPrice = 0;
  double _quantity = 1;
  double _iva = 0;
  double _totalWithIva = 0;

  bool _dropdownOpened = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _quantity = widget.item!.quantity;
      _unitPrice = widget.item!.unitPrice;
      _iva = widget.item!.iva;
      _calculateTotal();
    }
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
    final productsAsync = ref.watch(productNotifierProvider);
    final servicesAsync = ref.watch(serviceNotifierProvider);

    return CustomDialog(
      title: widget.item == null ? "Adicionar Item" : "Editar Item",
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== SEARCH DROPDOWN CUSTOM =====
              productsAsync.when(
                data: (products) => servicesAsync.when(
                  data: (services) {
                    final allItems = [
                      ...products.map((p) => ItemWrapper.product(p)),
                      ...services.map((s) => ItemWrapper.service(s)),
                    ];

                    // Filtra os itens já adicionados, mas mantém o item que está sendo editado
                    final filteredItems = allItems.where((item) {
                      if (widget.item != null && item.id == widget.item!.itemId)
                        return true;
                      if (widget.excludedItemIds.contains(item.id))
                        return false;
                      return item.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _dropdownOpened = !_dropdownOpened;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 26, 38, 51),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedItem?.toString() ??
                                        "Selecione um produto ou serviço",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ),
                                Icon(
                                  _dropdownOpened
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_dropdownOpened) ...[
                          const SizedBox(height: 8),
                          TextField(
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Pesquisar item"),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 26, 38, 51),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return ListTile(
                                  title: Text(
                                    item.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedItem = item;
                                      _unitPrice = item.price;
                                      _dropdownOpened = false;
                                      _calculateTotal();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text("Erro ao carregar serviços: $e"),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text("Erro ao carregar produtos: $e"),
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
            if (_formKey.currentState!.validate() && _selectedItem != null) {
              final result = ItemBudgetCreateDTO(
                itemId: _selectedItem!.id,
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
