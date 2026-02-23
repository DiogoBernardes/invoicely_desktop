import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_message_utils.dart';
import '../../../data/dto/category/category_create_dto.dart';
import '../../../data/dto/category/category_response_dto.dart';
import '../../../providers/categorie_provider.dart';
import '../custom_dialog.dart';

class AddExpenseCategoryDialog extends ConsumerStatefulWidget {
  const AddExpenseCategoryDialog({super.key});

  @override
  ConsumerState<AddExpenseCategoryDialog> createState() =>
      _AddExpenseCategoryDialogState();
}

class _AddExpenseCategoryDialogState
    extends ConsumerState<AddExpenseCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSaving = false;
  bool _nameError = false;
  String? _feedbackMessage;
  bool _feedbackError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() => _nameError = name.isEmpty);
    if (_nameError) return;

    setState(() => _isSaving = true);
    try {
      final created =
          await ref.read(categorieNotifierProvider.notifier).createCategory(
                CategoryCreateDTO(
                  name: name,
                  description: description,
                ),
              );
      if (!mounted) return;
      setState(() {
        _feedbackError = false;
        _feedbackMessage = 'Categoria criada com sucesso.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop<CategoryResponseDto>(context, created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackError = true;
        _feedbackMessage = ErrorMessageUtils.fromObject(
          e,
          fallback: 'Erro ao criar categoria.',
        );
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Nova Categoria de Despesa',
      content: Column(
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
          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Nome'),
            onChanged: (_) => setState(() => _nameError = false),
          ),
          if (_nameError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Insira o nome da categoria',
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
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
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
              : const Text('Criar'),
        ),
      ],
      maxWidthFactor: 0.45,
    );
  }
}
