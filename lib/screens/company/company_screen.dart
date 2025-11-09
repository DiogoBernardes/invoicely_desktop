import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/company_provider.dart';
import '../../widgets/company/protected_image.dart';
import '../../widgets/global_app_bar.dart';
import '../../data/dto/company/company_response_dto.dart';

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
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Confirmação',
                style: TextStyle(color: Colors.white)),
            content:
                Text(message, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child:
                    const Text('Não', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onCancel(CompanyResponseDTO company) async {
    if (await _confirmDialog('Tem certeza que quer cancelar as alterações?')) {
      setState(() {
        _editing = false;
        _newLogo = null;
        _newSignature = null;
        _newStamp = null;
        _emailController.text = company.email;
        _phoneController.text = company.phone;
        _addressController.text = company.address;
      });
    }
  }

  void _onSave() async {
    if (await _confirmDialog('Deseja salvar as alterações?')) {
      await ref.read(companyNotifierProvider.notifier).updateCompany(
            email: _emailController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            logoFile: _newLogo,
            signatureFile: _newSignature,
            stampFile: _newStamp,
          );

      setState(() {
        _editing = false;
        _newLogo = null;
        _newSignature = null;
        _newStamp = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(companyNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Perfil da Empresa'),
      backgroundColor: const Color(0xFF0F141A),
      body: companyAsync.when(
        data: (company) {
          if (company == null) {
            return const Center(
              child: Text(
                "Nenhuma empresa registada ainda.",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          if (!_editing) {
            _emailController.text = company.email;
            _phoneController.text = company.phone;
            _addressController.text = company.address;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com logo e nome
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'company-logo',
                          child: GestureDetector(
                            onTap: _editing
                                ? () async {
                                    final file = await _pickImage();
                                    if (file != null) {
                                      setState(() => _newLogo = file);
                                    }
                                  }
                                : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 130,
                                height: 130,
                                color: Colors.grey[800],
                                child: _newLogo != null
                                    ? Image.file(_newLogo!, fit: BoxFit.cover)
                                    : company.logoUrl != null
                                        ? ProtectedImage(
                                            url: company.logoUrl!,
                                            width: 130,
                                            height: 130,
                                          )
                                        : const Icon(Icons.business,
                                            size: 60, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                company.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Informações da Empresa",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(_editing ? Icons.close : Icons.edit,
                              size: 18),
                          label: Text(_editing ? 'Cancelar' : 'Editar'),
                          onPressed: () {
                            if (_editing) {
                              _onCancel(company);
                            } else {
                              setState(() => _editing = true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C2B39),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Campos principais
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Wrap(
                              runSpacing: 20,
                              spacing: 60,
                              children: [
                                _infoCard(Icons.badge, "NIF", company.nif,
                                    editable: false),
                                _infoCard(
                                    Icons.email, "Email", _emailController.text,
                                    editable: _editing,
                                    controller: _emailController),
                                _infoCard(Icons.phone, "Telefone",
                                    _phoneController.text,
                                    editable: _editing,
                                    controller: _phoneController),
                                _infoCard(Icons.location_on, "Endereço",
                                    _addressController.text,
                                    editable: _editing,
                                    controller: _addressController),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Assinatura / Carimbo
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF18222D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _imageSelector(
                                    title: 'Assinatura',
                                    currentUrl: company.signatureUrl,
                                    newFile: _newSignature,
                                    onPick: () async {
                                      final file = await _pickImage();
                                      if (file != null) {
                                        setState(() => _newSignature = file);
                                      }
                                    },
                                    editable: _editing,
                                    width: 200,
                                    height: 120,
                                  ),
                                  _imageSelector(
                                    title: 'Carimbo',
                                    currentUrl: company.stampUrl,
                                    newFile: _newStamp,
                                    onPick: () async {
                                      final file = await _pickImage();
                                      if (file != null) {
                                        setState(() => _newStamp = file);
                                      }
                                    },
                                    editable: _editing,
                                    width: 200,
                                    height: 120,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            if (_editing)
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: _onSave,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Guardar alterações'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                err.toString(),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    ref.read(companyNotifierProvider.notifier).fetchCompany(),
                child: const Text("Tentar novamente"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value,
      {bool editable = false, TextEditingController? controller}) {
    return SizedBox(
      width: 400,
      child: Card(
        color: const Color(0xFF1C2B39),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: editable && controller != null
                    ? TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: label,
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF253444),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(value.isEmpty ? '-' : value,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSelector({
    required String title,
    String? currentUrl,
    File? newFile,
    required VoidCallback onPick,
    required bool editable,
    double width = 160,
    double height = 100,
  }) {
    bool _hovering = false;

    return StatefulBuilder(
      builder: (context, setHoverState) {
        return Column(
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 8),
            MouseRegion(
              onEnter: (_) => setHoverState(() => _hovering = true),
              onExit: (_) => setHoverState(() => _hovering = false),
              child: GestureDetector(
                onTap: editable ? onPick : null,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: width,
                        height: height,
                        color: const Color(0xFF253444),
                        child: newFile != null
                            ? Image.file(newFile, fit: BoxFit.cover)
                            : currentUrl != null
                                ? ProtectedImage(url: currentUrl)
                                : const SizedBox.shrink(),
                      ),
                    ),
                    // Overlay de hover
                    if (editable && _hovering)
                      Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Alterar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Ícone padrão se não houver imagem
                    if (!editable && newFile == null && currentUrl == null)
                      Container(
                        width: width,
                        height: height,
                        color: const Color(0xFF253444),
                        child: const Center(
                          child: Icon(Icons.add_a_photo,
                              color: Colors.white24, size: 36),
                        ),
                      ),
                    if (editable && newFile == null && currentUrl == null)
                      Container(
                        width: width,
                        height: height,
                        color: const Color(0xFF253444),
                        child: const Center(
                          child: Icon(Icons.add_a_photo,
                              color: Colors.white54, size: 36),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
