import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/dto/company/company_response_dto.dart';
import '../../providers/company_provider.dart';
import '../../widgets/company/protected_image.dart';
import '../../widgets/dialogs/custom_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  bool _editing = false;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  File? _newLogo;
  File? _newSignature;
  File? _newStamp;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    ref.invalidate(companyNotifierProvider);
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  Future<bool> _confirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Confirmacao',
        icon: Icons.help_outline_rounded,
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textPrimaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nao'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _syncControllers(CompanyResponseDTO company) {
    _emailController.text = company.email;
    _phoneController.text = company.phone;
    _addressController.text = company.address;
  }

  Future<void> _onCancel(CompanyResponseDTO company) async {
    final confirmed = await _confirmDialog(
      'Tem a certeza que quer cancelar as alteracoes?',
    );
    if (!confirmed) return;

    setState(() {
      _editing = false;
      _newLogo = null;
      _newSignature = null;
      _newStamp = null;
      _syncControllers(company);
    });
  }

  Future<void> _onSave() async {
    final confirmed = await _confirmDialog('Deseja guardar as alteracoes?');
    if (!confirmed) return;

    await ref.read(companyNotifierProvider.notifier).updateCompany(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          logoFile: _newLogo,
          signatureFile: _newSignature,
          stampFile: _newStamp,
        );

    if (!mounted) return;
    setState(() {
      _editing = false;
      _newLogo = null;
      _newSignature = null;
      _newStamp = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(companyNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Perfil da Empresa'),
      drawer: const GlobalDrawer(),
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString(),
          onRetry: () =>
              ref.read(companyNotifierProvider.notifier).fetchCompany(),
        ),
        data: (company) {
          if (company == null) {
            return const _EmptyState();
          }

          if (!_editing) {
            _syncControllers(company);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1200;
              final horizontalPadding = compact ? 20.0 : 56.0;
              final topPadding = compact ? 24.0 : 34.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroCard(company, compact),
                    const SizedBox(height: 18),
                    _buildInfoCard(company, compact),
                    const SizedBox(height: 18),
                    _buildMediaCard(company, compact),
                    if (_editing) ...[
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _onCancel(company),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _onSave,
                              icon: const Icon(Icons.save_rounded, size: 18),
                              label: const Text('Guardar alteracoes'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(CompanyResponseDTO company, bool compact) {
    return GlassPanel(
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: !_editing
                ? null
                : () async {
                    final file = await _pickImage();
                    if (file == null) return;
                    setState(() => _newLogo = file);
                  },
            child: Container(
              width: compact ? 100 : 124,
              height: compact ? 100 : 124,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppTheme.borderColor.withOpacity(0.85)),
                color: AppTheme.panelColorSoft.withOpacity(0.7),
              ),
              clipBehavior: Clip.antiAlias,
              child: _newLogo != null
                  ? Image.file(_newLogo!, fit: BoxFit.cover)
                  : company.logoUrl != null
                      ? ProtectedImage(
                          url: company.logoUrl!,
                          width: compact ? 100 : 124,
                          height: compact ? 100 : 124,
                        )
                      : const Icon(
                          Icons.business_rounded,
                          size: 52,
                          color: AppTheme.textSecondaryColor,
                        ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dados institucionais e documentos oficiais da empresa.',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                _TagLabel(text: 'NIF ${company.nif}'),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (_editing) {
                _onCancel(company);
                return;
              }
              setState(() => _editing = true);
            },
            icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded,
                size: 18),
            label: Text(_editing ? 'Cancelar' : 'Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(CompanyResponseDTO company, bool compact) {
    return GlassPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informacao de contacto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          if (compact) ...[
            _InfoFieldCard(
              icon: Icons.badge_rounded,
              label: 'NIF',
              value: company.nif,
              editable: false,
            ),
            const SizedBox(height: 10),
            _InfoFieldCard(
              icon: Icons.email_rounded,
              label: 'Email',
              value: _emailController.text,
              editable: _editing,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            _InfoFieldCard(
              icon: Icons.phone_rounded,
              label: 'Telefone',
              value: _phoneController.text,
              editable: _editing,
              controller: _phoneController,
            ),
            const SizedBox(height: 10),
            _InfoFieldCard(
              icon: Icons.location_on_rounded,
              label: 'Endereco',
              value: _addressController.text,
              editable: _editing,
              controller: _addressController,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _InfoFieldCard(
                    icon: Icons.badge_rounded,
                    label: 'NIF',
                    value: company.nif,
                    editable: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoFieldCard(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: _emailController.text,
                    editable: _editing,
                    controller: _emailController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoFieldCard(
                    icon: Icons.phone_rounded,
                    label: 'Telefone',
                    value: _phoneController.text,
                    editable: _editing,
                    controller: _phoneController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoFieldCard(
                    icon: Icons.location_on_rounded,
                    label: 'Endereco',
                    value: _addressController.text,
                    editable: _editing,
                    controller: _addressController,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaCard(CompanyResponseDTO company, bool compact) {
    return GlassPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assinatura e carimbo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              _MediaSelector(
                title: 'Assinatura',
                width: compact ? 240 : 300,
                height: 130,
                currentUrl: company.signatureUrl,
                newFile: _newSignature,
                editable: _editing,
                onPick: () async {
                  final file = await _pickImage();
                  if (file == null) return;
                  setState(() => _newSignature = file);
                },
              ),
              _MediaSelector(
                title: 'Carimbo',
                width: compact ? 240 : 300,
                height: 130,
                currentUrl: company.stampUrl,
                newFile: _newStamp,
                editable: _editing,
                onPick: () async {
                  final file = await _pickImage();
                  if (file == null) return;
                  setState(() => _newStamp = file);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoFieldCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool editable;
  final TextEditingController? controller;

  const _InfoFieldCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.editable,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.7)),
        color: AppTheme.panelColorSoft.withOpacity(0.52),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: editable && controller != null
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      isDense: true,
                      fillColor: AppTheme.panelColor.withOpacity(0.75),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value.isEmpty ? '-' : value,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MediaSelector extends StatefulWidget {
  final String title;
  final String? currentUrl;
  final File? newFile;
  final bool editable;
  final Future<void> Function() onPick;
  final double width;
  final double height;

  const _MediaSelector({
    required this.title,
    required this.currentUrl,
    required this.newFile,
    required this.editable,
    required this.onPick,
    required this.width,
    required this.height,
  });

  @override
  State<_MediaSelector> createState() => _MediaSelectorState();
}

class _MediaSelectorState extends State<_MediaSelector> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.newFile != null || widget.currentUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.editable ? widget.onPick : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.borderColor.withOpacity(0.75)),
                color: AppTheme.panelColorSoft.withOpacity(0.66),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.newFile != null)
                    Image.file(widget.newFile!, fit: BoxFit.cover)
                  else if (widget.currentUrl != null)
                    ProtectedImage(url: widget.currentUrl!)
                  else
                    const Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 30,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  if (widget.editable && _hovering)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          hasImage ? 'Alterar' : 'Adicionar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TagLabel extends StatelessWidget {
  final String text;

  const _TagLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.38)),
        color: AppTheme.primaryColor.withOpacity(0.15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 44,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 12),
            Text(
              'Nenhuma empresa registada.',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
