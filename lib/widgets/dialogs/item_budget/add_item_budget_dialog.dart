import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_message_utils.dart';
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

class ItemWrapper {
  final String id;
  final String name;
  final double price;
  final String type;
  final double stockQuantity;
  final bool lowStock;
  final ProductResponseDTO? product;
  final ServiceResponseDTO? service;

  ItemWrapper.product(this.product)
      : id = product!.id,
        name = product.name,
        price = product.price,
        type = 'Produto',
        stockQuantity = product.stockQuantity,
        lowStock = product.lowStock,
        service = null;

  ItemWrapper.service(this.service)
      : id = service!.id,
        name = service.name,
        price = service.price,
        type = 'Servico',
        stockQuantity = 0,
        lowStock = false,
        product = null;

  bool get isProduct => type == 'Produto';

  @override
  bool operator ==(other) =>
      other is ItemWrapper && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => '$name ($type - EUR ${price.toStringAsFixed(2)})';
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();

  ItemWrapper? _selectedItem;
  String _searchQuery = '';

  double _unitPrice = 0;
  double _quantity = 1;
  double _iva = 0;
  double _totalWithIva = 0;

  bool _dropdownOpened = false;
  String? _feedbackMessage;

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
      title: widget.item == null ? 'Adicionar Item' : 'Editar Item',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.45),
                    ),
                  ),
                  child: Text(
                    _feedbackMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              productsAsync.when(
                data: (products) => servicesAsync.when(
                  data: (services) {
                    final allItems = [
                      ...products.map((p) => ItemWrapper.product(p)),
                      ...services.map((s) => ItemWrapper.service(s)),
                    ];

                    final filteredItems = allItems.where((item) {
                      if (widget.item != null && item.id == widget.item!.itemId) {
                        return true;
                      }
                      if (widget.excludedItemIds.contains(item.id)) return false;
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
                              horizontal: 12,
                              vertical: 16,
                            ),
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
                                        'Selecione um produto ou servico',
                                    style: const TextStyle(color: Colors.white70),
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
                            decoration: _inputDecoration('Pesquisar item'),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 220,
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
                                  subtitle: item.isProduct
                                      ? Text(
                                          'Stock: ${item.stockQuantity.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: item.lowStock
                                                ? Colors.orangeAccent
                                                : Colors.white54,
                                          ),
                                        )
                                      : null,
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
                        ],
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text(
                    ErrorMessageUtils.fromObject(
                      e,
                      fallback: 'Erro ao carregar servicos.',
                    ),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text(
                  ErrorMessageUtils.fromObject(
                    e,
                    fallback: 'Erro ao carregar produtos.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity.toString(),
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Quantidade'),
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
                decoration: _inputDecoration('Preco Unitario'),
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
                decoration: _inputDecoration('IVA (%)'),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  _iva = double.tryParse(v) ?? 0;
                  _calculateTotal();
                },
              ),
              const SizedBox(height: 16),
              if (_selectedItem != null && _selectedItem!.isProduct)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Stock disponivel: ${_selectedItem!.stockQuantity.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _selectedItem!.lowStock
                          ? Colors.orangeAccent
                          : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Total (IVA incluido): EUR ${_totalWithIva.toStringAsFixed(2)}',
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
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedItem != null) {
              if (_selectedItem!.isProduct &&
                  _quantity > _selectedItem!.stockQuantity) {
                setState(() {
                  _feedbackMessage = 'Quantidade superior ao stock disponivel.';
                });
                return;
              }

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
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
