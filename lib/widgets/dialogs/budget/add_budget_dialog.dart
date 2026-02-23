import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/error_message_utils.dart';
import '../../../data/dto/budget/budget_create_dto.dart';
import '../../../data/dto/item_budget/item_budget_create_dto.dart';
import '../../../providers/client_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/service_provider.dart';
import '../custom_dialog.dart';
import '../item_budget/add_item_budget_dialog.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final Function(BudgetCreateDTO) onBudgetAdded;

  const AddBudgetDialog({super.key, required this.onBudgetAdded});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEntityId;
  late String _selectedState;
  DateTime? _selectedDate = DateTime.now();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  List<ItemBudgetCreateDTO> _items = [];
  bool _entityError = false;
  bool _stateError = false;
  bool _dateError = false;

  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _selectedState = 'PENDENTE';
    _stateController.text = _selectedState;
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

  List<ItemBudgetCreateDTO> get _paginatedItems {
    final start = _currentPage * _itemsPerPage;
    final end = (_currentPage + 1) * _itemsPerPage;
    return _items.sublist(start, end > _items.length ? _items.length : end);
  }

  int get _totalPages => (_items.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final entities = ref.watch(clientNotifierProvider);
    final products = ref.watch(productNotifierProvider).value ?? [];
    final services = ref.watch(serviceNotifierProvider).value ?? [];

    String getItemName(String itemId) {
      for (final p in products) {
        if (p.id == itemId) return p.name;
      }
      for (final s in services) {
        if (s.id == itemId) return s.name;
      }
      return itemId;
    }

    double calculatedTotal() {
      final totalItems = _items.fold<double>(
        0,
        (sum, item) =>
            sum + item.unitPrice * item.quantity * (1 + item.iva / 100),
      );

      final discountPercentage = double.tryParse(_discountController.text) ?? 0;
      final discountValue = totalItems * (discountPercentage / 100);

      return totalItems - discountValue;
    }

    return CustomDialog(
      title: 'Adicionar Orçamento',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            entities.when(
              data: (list) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu<String>(
                      controller: _entityController,
                      enableFilter: true,
                      label: const Text('Entidade'),
                      width: 850,
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 26, 38, 51),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownMenuEntries: list
                          .map((e) => DropdownMenuEntry(
                                value: e.id,
                                label: e.name,
                              ))
                          .toList(),
                      onSelected: (value) {
                        setState(() {
                          _selectedEntityId = value;
                          _entityError = false;
                        });
                      },
                    ),
                    if (_entityError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Selecione uma entidade',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(
                ErrorMessageUtils.fromObject(
                  e,
                  fallback: 'Erro ao carregar entidades.',
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<String>(
                  controller: _stateController,
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
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'PENDENTE', label: 'Pendente'),
                    DropdownMenuEntry(value: 'ACEITE', label: 'Aprovado'),
                    DropdownMenuEntry(value: 'REJEITADO', label: 'Rejeitado'),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _selectedState = value!;
                      _stateError = false;
                    });
                  },
                ),
                if (_stateError)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Selecione o estado',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  readOnly: true,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Data').copyWith(
                    hintText: _selectedDate != null
                        ? _selectedDate!.toIso8601String().split('T')[0]
                        : '',
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                        _dateError = false;
                      });
                    }
                  },
                ),
                if (_dateError)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Selecione uma data',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Desconto
            TextFormField(
              controller: _discountController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Desconto"),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {
                  _totalController.text = calculatedTotal().toStringAsFixed(2);
                });
              },
            ),
            const SizedBox(height: 16),

            // Total
            TextFormField(
              readOnly: true,
              controller: _totalController
                ..text = calculatedTotal().toStringAsFixed(2),
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Total"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Lista de itens...
            if (_items.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Itens adicionados:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  ..._paginatedItems.map(
                    (item) => ListTile(
                      title: Text('Item: ${getItemName(item.itemId)}',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          'Qtd: ${item.quantity}, Preço unit.: ${item.unitPrice}, IVA: ${item.iva}',
                          style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _items.remove(item);
                            if (_currentPage > 0 &&
                                _currentPage >= _totalPages) {
                              _currentPage--;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  if (_totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text(
                          'Página ${_currentPage + 1} de $_totalPages',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward,
                              color: Colors.white),
                          onPressed: _currentPage < _totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 16),

            // Botão adicionar item
            ElevatedButton(
              onPressed: () async {
                final newItem = await showDialog<ItemBudgetCreateDTO>(
                  context: context,
                  builder: (_) => AddItemDialog(
                      excludedItemIds: _items.map((e) => e.itemId).toList()),
                );
                if (newItem != null) {
                  setState(() {
                    _items.add(newItem);
                    _totalController.text =
                        calculatedTotal().toStringAsFixed(2);
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
            setState(() {
              _entityError =
                  _selectedEntityId == null || _selectedEntityId!.isEmpty;
              _stateError = _selectedState.isEmpty;
              _dateError = _selectedDate == null;
            });

            if (!_entityError && !_stateError && !_dateError) {
              final dto = BudgetCreateDTO(
                entityId: _selectedEntityId ?? '',
                date: _selectedDate!,
                discount: double.tryParse(_discountController.text) ?? 0,
                total: double.tryParse(_totalController.text) ?? 0,
                state: _selectedState,
                items: _items,
              );
              widget.onBudgetAdded(dto);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 36, 54, 71),
            foregroundColor: Colors.white,
          ),
          child: const Text("Adicionar"),
        ),
      ],
    );
  }
}
