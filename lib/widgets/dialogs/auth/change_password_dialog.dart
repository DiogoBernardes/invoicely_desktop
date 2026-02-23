import 'package:flutter/material.dart';

import '../../../core/errors/error_message_utils.dart';
import '../../../data/services/auth_service.dart';
import '../custom_dialog.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _codeSent = false;
  String? _feedbackMessage;
  bool _feedbackSuccess = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showMessage(
        'Preencha todos os campos da password.',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await _authService.requestPasswordChange(
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmNewPassword: _confirmPasswordController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _codeSent = true);
      _showMessage(message, isSuccess: true);
    } catch (e) {
      _showMessage(
        ErrorMessageUtils.fromObject(
          e,
          fallback: 'Nao foi possivel enviar o codigo.',
        ),
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmChange() async {
    if (_tokenController.text.trim().isEmpty) {
      _showMessage(
        'Introduza o codigo de confirmacao.',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await _authService.confirmPasswordChange(
        tokenCode: _tokenController.text.trim(),
      );
      if (!mounted) return;
      _showMessage(message, isSuccess: true);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showMessage(
        ErrorMessageUtils.fromObject(
          e,
          fallback: 'Nao foi possivel alterar a password.',
        ),
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {required bool isSuccess}) {
    if (!mounted) return;
    setState(() {
      _feedbackMessage = message;
      _feedbackSuccess = isSuccess;
    });
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color.fromARGB(255, 26, 38, 51),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _feedbackBox() {
    if (_feedbackMessage == null || _feedbackMessage!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final tone = _feedbackSuccess ? Colors.greenAccent : Colors.redAccent;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withOpacity(0.4)),
      ),
      child: Text(
        _feedbackMessage!,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Alterar Password',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _feedbackBox(),
          TextField(
            controller: _oldPasswordController,
            obscureText: true,
            decoration: _decoration('Password atual'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: _decoration('Nova password'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: _decoration('Confirmar nova password'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _requestCode,
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Enviar codigo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tokenController,
            enabled: _codeSent,
            decoration: _decoration('Codigo de confirmacao'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading || !_codeSent ? null : _confirmChange,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }
}
