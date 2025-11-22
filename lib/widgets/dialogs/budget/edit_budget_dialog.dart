import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../data/dto/budget/budget_response_dto.dart';
import '../../../data/dto/budget/budget_update_dto.dart';
import '../../../data/dto/item_budget/item_budget_create_dto.dart';
import '../../../data/dto/item_budget/item_budget_response_dto.dart';
import '../../../data/dto/item_budget/item_budget_update_dto.dart';
import '../../../providers/client_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/service_provider.dart';
import '../custom_dialog.dart';
import '../item_budget/add_item_budget_dialog.dart';
import '../item_budget/edit_item_budget_dialog.dart';

class EditBudgetDialog extends ConsumerStatefulWidget {
  final BudgetResponseDTO budget;
  final Function(BudgetUpdateDTO) onBudgetUpdated;

  const EditBudgetDialog({
    super.key,
    required this.budget,
    required this.onBudgetUpdated,
  });

  @override
  ConsumerState<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends ConsumerState<EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEntityId;
  String _selectedState = 'PENDENTE';
  late DateTime _selectedDate;
  late TextEditingController _discountController;
  late TextEditingController _totalController;
  late TextEditingController _entityController;

  late List<ItemBudgetResponseDTO> _originalItems;
  late List<ItemBudgetResponseDTO> _addedItems;
  late List<String> _removedItemIds;

  final Map<String, String> stateOptions = {
    'PENDENTE': 'Pendente',
    'ACEITE': 'Aprovado',
    'REJEITADO': 'Cancelado',
  };

  @override
  void initState() {
    super.initState();

    _selectedEntityId = widget.budget.entityId;
    _entityController = TextEditingController(text: widget.budget.entityName);
    _selectedDate = widget.budget.date;
    _discountController =
        TextEditingController(text: widget.budget.discount.toString());
    _totalController =
        TextEditingController(text: widget.budget.total.toString());
    _selectedState = widget.budget.state;

    _originalItems = List.from(widget.budget.items);
    _addedItems = [];
    _removedItemIds = [];

    _recalculateTotal();
  }

  List<ItemBudgetResponseDTO> get _displayItems => [
        ..._originalItems.where((i) => !_removedItemIds.contains(i.id)),
        ..._addedItems,
      ];

  void _recalculateTotal() {
    double totalItems = _displayItems.fold(0, (sum, item) {
      return sum + item.unitPrice * item.quantity * (1 + item.iva / 100);
    });
    double discountPercent = double.tryParse(_discountController.text) ?? 0;
    double totalFinal = totalItems - (totalItems * discountPercent / 100);
    _totalController.text = totalFinal.toStringAsFixed(2);
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
    final entities = ref.watch(clientNotifierProvider);
    final products = ref.watch(productNotifierProvider).value ?? [];
    final services = ref.watch(serviceNotifierProvider).value ?? [];

    String getItemName(String itemId) {
      final product = products.firstWhereOrNull((p) => p.id == itemId);
      if (product != null) return product.name;
      final service = services.firstWhereOrNull((s) => s.id == itemId);
      if (service != null) return service.name;
      return itemId;
    }

    return CustomDialog(
      title: 'Editar Orçamento',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown de entidades
              entities.when(
                data: (list) {
                  if (_entityController.text.isEmpty &&
                      _selectedEntityId != null) {
                    final entity = list.firstWhere(
                      (e) => e.id == _selectedEntityId,
                      orElse: () => list.first,
                    );
                    _entityController.text = entity.name;
                  }

                  return DropdownMenu<String>(
                    controller: _entityController,
                    enableFilter: true,
                    label: const Text('Entidade'),
                    width: 850,
                    dropdownMenuEntries: list
                        .map((e) =>
                            DropdownMenuEntry(value: e.id, label: e.name))
                        .toList(),
                    onSelected: (value) =>
                        setState(() => _selectedEntityId = value),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Erro ao carregar entidades: $e'),
              ),
              const SizedBox(height: 16),

              // Dropdown de estado
              DropdownMenu<String>(
                controller: TextEditingController(text: _selectedState),
                initialSelection: _selectedState,
                enableFilter: false,
                label: const Text('Estado'),
                width: 850,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 26, 38, 51),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownMenuEntries: stateOptions.entries
                    .map((e) => DropdownMenuEntry(value: e.key, label: e.value))
                    .toList(),
                onSelected: (value) => setState(() => _selectedState = value!),
              ),
              const SizedBox(height: 16),

              // Data
              TextFormField(
                readOnly: true,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Data').copyWith(
                  hintText: _selectedDate.toIso8601String().split('T')[0],
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 16),

              // Desconto
              TextFormField(
                controller: _discountController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Desconto (%)"),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _recalculateTotal()),
              ),
              const SizedBox(height: 16),

              // Total
              TextFormField(
                controller: _totalController,
                readOnly: true,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white70),
                decoration: _inputDecoration("Total"),
              ),
              const SizedBox(height: 16),

              // Lista de itens
              if (_displayItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Itens do orçamento:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ..._displayItems.map(
                      (item) => ListTile(
                        title: Text('Item: ${getItemName(item.itemId)}',
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                            'Qtd: ${item.quantity}, Preço unit.: ${item.unitPrice}, IVA: ${item.iva}',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Editar item
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final edited =
                                    await showDialog<ItemBudgetCreateDTO>(
                                  context: context,
                                  builder: (_) => EditItemBudgetDialog(
                                    item: ItemBudgetCreateDTO(
                                      itemId: item.itemId,
                                      quantity: item.quantity,
                                      unitPrice: item.unitPrice,
                                      iva: item.iva,
                                    ),
                                  ),
                                );
                                if (edited != null) {
                                  setState(() {
                                    item.quantity = edited.quantity;
                                    item.unitPrice = edited.unitPrice;
                                    item.iva = edited.iva;
                                    _recalculateTotal();
                                  });
                                }
                              },
                            ),
                            // Remover item
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (_originalItems.contains(item)) {
                                    _removedItemIds.add(item.id);
                                  } else {
                                    _addedItems.remove(item);
                                  }
                                  _recalculateTotal();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Adicionar item
              ElevatedButton(
                onPressed: () async {
                  final newItem = await showDialog<ItemBudgetCreateDTO>(
                    context: context,
                    builder: (_) => const AddItemDialog(),
                  );
                  if (newItem != null) {
                    setState(() {
                      final existingOriginal = _originalItems.firstWhereOrNull(
                        (i) =>
                            i.itemId == newItem.itemId &&
                            !_removedItemIds.contains(i.id),
                      );
                      final existingAdded = _addedItems
                          .firstWhereOrNull((i) => i.itemId == newItem.itemId);

                      if (existingOriginal != null) {
                        existingOriginal.quantity += newItem.quantity;
                      } else if (existingAdded != null) {
                        existingAdded.quantity += newItem.quantity;
                      } else {
                        _addedItems.add(ItemBudgetResponseDTO(
                          id: UniqueKey().toString(),
                          budgetId: widget.budget.id,
                          itemId: newItem.itemId,
                          itemName: getItemName(newItem.itemId),
                          quantity: newItem.quantity,
                          unitPrice: newItem.unitPrice,
                          iva: newItem.iva,
                          totalWithIva: newItem.quantity *
                              newItem.unitPrice *
                              (1 + newItem.iva / 100),
                        ));
                      }
                      _recalculateTotal();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 26, 38, 51),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Adicionar Item"),
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
              final Map<String, ItemBudgetUpdateDTO> itemsMap = {};

              for (var i in _originalItems) {
                if (!_removedItemIds.contains(i.id)) {
                  itemsMap[i.itemId] = ItemBudgetUpdateDTO(
                    itemId: i.itemId,
                    quantity: i.quantity,
                    unitPrice: i.unitPrice,
                    iva: i.iva,
                  );
                }
              }

              for (var i in _addedItems) {
                if (itemsMap.containsKey(i.itemId)) {
                  final existing = itemsMap[i.itemId]!;
                  itemsMap[i.itemId] = ItemBudgetUpdateDTO(
                    itemId: existing.itemId,
                    quantity: existing.quantity + i.quantity,
                    unitPrice: i.unitPrice,
                    iva: i.iva,
                  );
                } else {
                  itemsMap[i.itemId] = ItemBudgetUpdateDTO(
                    itemId: i.itemId,
                    quantity: i.quantity,
                    unitPrice: i.unitPrice,
                    iva: i.iva,
                  );
                }
              }

              final dto = BudgetUpdateDTO(
                entityId: _selectedEntityId ?? '',
                date: _selectedDate,
                discount: double.tryParse(_discountController.text) ?? 0,
                total: double.tryParse(_totalController.text) ?? 0,
                state: _selectedState,
                items: itemsMap.values.toList(),
                removedItemIds: _removedItemIds,
              );

              widget.onBudgetUpdated(dto);
              Navigator.pop(context);
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
