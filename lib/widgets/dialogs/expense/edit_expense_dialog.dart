import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_message_utils.dart';
import '../../../data/dto/category/category_response_dto.dart';
import '../../../data/dto/expense/expense_response_dto.dart';
import '../../../data/dto/expense/expense_update_dto.dart';
import '../../../providers/categorie_provider.dart';
import '../../../providers/payment_method_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/supplier_provider.dart';
import '../custom_dialog.dart';
import 'add_expense_category_dialog.dart';

class EditExpenseDialog extends ConsumerStatefulWidget {
  final ExpenseResponseDto expense;
  final Future<void> Function(ExpenseUpdateDTO) onExpenseUpdated;

  const EditExpenseDialog({
    super.key,
    required this.expense,
    required this.onExpenseUpdated,
  });

  @override
  ConsumerState<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends ConsumerState<EditExpenseDialog> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();

  String? _selectedEntityId;
  String? _selectedCategoryId;
  String? _selectedPaymentMethodId;
  String? _selectedStockItemId;
  late DateTime _selectedDate;
  bool _restockProduct = false;
  bool _hadInitialStockAdjustment = false;

  bool _entityError = false;
  bool _valueError = false;
  bool _descriptionError = false;
  bool _categoryError = false;
  bool _paymentMethodError = false;
  bool _stockItemError = false;
  bool _stockQuantityError = false;
  bool _isSaving = false;
  String? _feedbackMessage;
  bool _feedbackError = false;

  @override
  void initState() {
    super.initState();
    _selectedEntityId = widget.expense.entityId;
    _selectedCategoryId = widget.expense.category.id;
    _selectedPaymentMethodId = widget.expense.paymentMethod.id;
    _selectedDate = widget.expense.date;
    _valueController.text = widget.expense.value.toStringAsFixed(2);
    _descriptionController.text = widget.expense.description;

    _hadInitialStockAdjustment = widget.expense.stockItemId != null;
    _restockProduct = _hadInitialStockAdjustment;
    _selectedStockItemId = widget.expense.stockItemId;
    if (widget.expense.stockQuantity != null) {
      _stockQuantityController.text = widget.expense.stockQuantity!.toString();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
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

  double? _parseAmount(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _submit() async {
    final parsedAmount = _parseAmount(_valueController.text);
    final parsedStockQuantity = _parseAmount(_stockQuantityController.text);

    setState(() {
      _entityError = _selectedEntityId == null || _selectedEntityId!.isEmpty;
      _valueError = parsedAmount == null || parsedAmount <= 0;
      _descriptionError = _descriptionController.text.trim().isEmpty;
      _categoryError =
          _selectedCategoryId == null || _selectedCategoryId!.isEmpty;
      _paymentMethodError =
          _selectedPaymentMethodId == null || _selectedPaymentMethodId!.isEmpty;
      _stockItemError = _restockProduct &&
          (_selectedStockItemId == null || _selectedStockItemId!.isEmpty);
      _stockQuantityError =
          _restockProduct && (parsedStockQuantity == null || parsedStockQuantity <= 0);
    });

    if (_entityError ||
        _valueError ||
        _descriptionError ||
        _categoryError ||
        _paymentMethodError ||
        _stockItemError ||
        _stockQuantityError) {
      return;
    }

    final dto = ExpenseUpdateDTO(
      entityId: _selectedEntityId!,
      date: _selectedDate,
      value: parsedAmount!,
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      paymentMethodId: _selectedPaymentMethodId!,
      stockItemId: _restockProduct ? _selectedStockItemId : null,
      stockQuantity: _restockProduct ? parsedStockQuantity : null,
      clearStockAdjustment: !_restockProduct && _hadInitialStockAdjustment,
    );

    setState(() => _isSaving = true);
    try {
      await widget.onExpenseUpdated(dto);
      if (!mounted) return;
      setState(() {
        _feedbackError = false;
        _feedbackMessage = 'Despesa atualizada com sucesso.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackError = true;
        _feedbackMessage = ErrorMessageUtils.fromObject(
          e,
          fallback: 'Erro ao atualizar despesa.',
        );
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final CategoryResponseDto? created = await showDialog<CategoryResponseDto>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddExpenseCategoryDialog(),
    );
    if (created == null || !mounted) return;

    setState(() {
      _selectedCategoryId = created.id;
      _categoryError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierNotifierProvider);
    final categoriesAsync = ref.watch(categorieNotifierProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodNotifierProvider);
    final productsAsync = ref.watch(productNotifierProvider);
    final selectedDateText = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return CustomDialog(
      title: 'Editar Despesa',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: (_feedbackError ? Colors.redAccent : Colors.greenAccent)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_feedbackError ? Colors.redAccent : Colors.greenAccent)
                        .withOpacity(0.45),
                  ),
                ),
                child: Text(
                  _feedbackMessage!,
                  style: TextStyle(
                    color: _feedbackError ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            suppliersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(
                ErrorMessageUtils.fromObject(
                  e,
                  fallback: 'Erro ao carregar fornecedores.',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              data: (suppliers) {
                final selectedValue = suppliers.any(
                  (supplier) => supplier.id == _selectedEntityId,
                )
                    ? _selectedEntityId
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: _inputDecoration('Fornecedor'),
                      dropdownColor: const Color.fromARGB(255, 36, 54, 71),
                      items: suppliers
                          .map(
                            (supplier) => DropdownMenuItem<String>(
                              value: supplier.id,
                              child: Text(supplier.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
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
                          'Selecione um fornecedor',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              enabled: !_isSaving,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Data').copyWith(
                hintText: selectedDateText,
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate == null) return;
                setState(() => _selectedDate = pickedDate);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              enabled: !_isSaving,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Valor (EUR)'),
              onChanged: (_) => setState(() => _valueError = false),
            ),
            if (_valueError)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Insira um valor valido',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSaving,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Descricao'),
              onChanged: (_) => setState(() => _descriptionError = false),
            ),
            if (_descriptionError)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Insira uma descricao',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(
                ErrorMessageUtils.fromObject(
                  e,
                  fallback: 'Erro ao carregar categorias.',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              data: (categories) {
                final selectedValue = categories
                        .any((category) => category.id == _selectedCategoryId)
                    ? _selectedCategoryId
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Categoria',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isSaving ? null : _showAddCategoryDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Nova categoria'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: _inputDecoration('Selecionar categoria'),
                      dropdownColor: const Color.fromARGB(255, 36, 54, 71),
                      items: categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategoryId = value;
                                _categoryError = false;
                              });
                            },
                    ),
                    if (_categoryError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Selecione uma categoria',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            paymentMethodsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(
                ErrorMessageUtils.fromObject(
                  e,
                  fallback: 'Erro ao carregar metodos de pagamento.',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              data: (paymentMethods) {
                final selectedValue = paymentMethods.any(
                  (method) => method.id == _selectedPaymentMethodId,
                )
                    ? _selectedPaymentMethodId
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: _inputDecoration('Metodo de pagamento'),
                      dropdownColor: const Color.fromARGB(255, 36, 54, 71),
                      items: paymentMethods
                          .map(
                            (method) => DropdownMenuItem<String>(
                              value: method.id,
                              child: Text(method.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _selectedPaymentMethodId = value;
                                _paymentMethodError = false;
                              });
                            },
                    ),
                    if (_paymentMethodError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Selecione um metodo de pagamento',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _restockProduct,
              title: const Text('Repor stock com esta despesa'),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _restockProduct = value;
                        if (!value) {
                          _selectedStockItemId = null;
                          _stockQuantityController.clear();
                        }
                        _stockItemError = false;
                        _stockQuantityError = false;
                      });
                    },
            ),
            if (_restockProduct) ...[
              const SizedBox(height: 8),
              productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text(
                  ErrorMessageUtils.fromObject(
                    e,
                    fallback: 'Erro ao carregar produtos.',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                data: (products) {
                  final selectedValue = products.any(
                    (product) => product.id == _selectedStockItemId,
                  )
                      ? _selectedStockItemId
                      : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedValue,
                        decoration: _inputDecoration('Produto para stock'),
                        dropdownColor: const Color.fromARGB(255, 36, 54, 71),
                        items: products
                            .map(
                              (product) => DropdownMenuItem<String>(
                                value: product.id,
                                child: Text(
                                  '${product.name} (stock: ${product.stockQuantity.toStringAsFixed(2)})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedStockItemId = value;
                                  _stockItemError = false;
                                });
                              },
                      ),
                      if (_stockItemError)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Selecione um produto',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _stockQuantityController,
                        enabled: !_isSaving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Quantidade de reposicao'),
                        onChanged: (_) =>
                            setState(() => _stockQuantityError = false),
                      ),
                      if (_stockQuantityError)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Insira uma quantidade valida',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child:
              const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
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
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
