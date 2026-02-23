import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/supplier/supplier_create_dto.dart';
import '../../data/dto/supplier/supplier_response_dto.dart';
import '../../data/dto/supplier/supplier_update_dto.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/dialogs/supplier/add_supplier_dialog.dart';
import '../../widgets/dialogs/supplier/edit_supplier_dialog.dart';
import '../../widgets/dialogs/supplier/remove_supplier_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';

class SupplierScreen extends ConsumerStatefulWidget {
  const SupplierScreen({super.key});

  @override
  ConsumerState<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends ConsumerState<SupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  String _searchQuery = '';
  _SupplierSort _sort = _SupplierSort.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Fornecedores'),
      drawer: const GlobalDrawer(),
      body: TablePageShell(
        title: 'Fornecedores',
        icon: Icons.inventory_2_rounded,
        actions: [
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(supplierNotifierProvider.notifier).loadSuppliers(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Atualizar'),
          ),
          ElevatedButton.icon(
            onPressed: _showAddSupplierDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo Fornecedor'),
          ),
        ],
        filters: Row(
          children: [
            Expanded(
              child: TableSearchField(
                controller: _searchController,
                hintText: 'Pesquisar por nome, email, NIF ou telefone',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<_SupplierSort>(
                value: _sort,
                decoration: const InputDecoration(
                  labelText: 'Ordenar',
                  prefixIcon: Icon(Icons.swap_vert_rounded, size: 18),
                ),
                items: _SupplierSort.values
                    .map(
                      (value) => DropdownMenuItem<_SupplierSort>(
                        value: value,
                        child: Text(_sortLabel(value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _sort = value;
                    _currentPage = 0;
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(width: 12),
              _activeFilterPill(),
            ],
          ],
        ),
        content: suppliersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(
              ErrorMessageUtils.fromObject(
                e,
                fallback: 'Erro ao carregar fornecedores.',
              ),
            ),
          ),
          data: (suppliers) => _buildTableContent(suppliers),
        ),
      ),
    );
  }

  Widget _buildTableContent(List<SupplierResponseDto> suppliers) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(query) ||
          supplier.email.toLowerCase().contains(query) ||
          supplier.nif.toLowerCase().contains(query) ||
          supplier.phone.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _SupplierSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _SupplierSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _SupplierSort.nifAsc:
          return a.nif.compareTo(b.nif);
        case _SupplierSort.nifDesc:
          return b.nif.compareTo(a.nif);
      }
    });

    final totalPages = ((filtered.length + _rowsPerPage - 1) / _rowsPerPage)
        .floor()
        .clamp(1, 999999);
    final effectivePage = _currentPage.clamp(0, totalPages - 1);
    final startIndex = effectivePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    final pageSuppliers = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <SupplierResponseDto>[];
    final displaySuppliers = List<SupplierResponseDto?>.generate(
      _rowsPerPage,
      (index) => index < pageSuppliers.length ? pageSuppliers[index] : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppTableContainer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = max(constraints.maxWidth, 900.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: DataTable(
                      headingRowHeight: 56,
                      dataRowMinHeight: 54,
                      dataRowMaxHeight: 62,
                      horizontalMargin: 0,
                      columnSpacing: 0,
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.panelColorSoft.withOpacity(0.95),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.primaryColor.withOpacity(0.15);
                        }
                        return AppTheme.panelColor.withOpacity(0.78);
                      }),
                      columns: const [
                        DataColumn(
                          label: _HeaderCell('Nome'),
                        ),
                        DataColumn(
                          label: _HeaderCell('NIF'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Endereco'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Telefone'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Email'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Acoes'),
                        ),
                      ],
                      rows: displaySuppliers
                          .map((supplier) => _buildRow(supplier))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        TablePaginationBar(
          currentPage: effectivePage + 1,
          totalPages: totalPages,
          onPrevious: effectivePage > 0
              ? () => setState(() => _currentPage = effectivePage - 1)
              : null,
          onNext: effectivePage < totalPages - 1
              ? () => setState(() => _currentPage = effectivePage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _activeFilterPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.primaryColor.withOpacity(0.16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_alt_rounded, size: 16),
          const SizedBox(width: 8),
          Text('"$_searchQuery"'),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _currentPage = 0;
              });
            },
            child: const Icon(Icons.close_rounded, size: 16),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(SupplierResponseDto? supplier) {
    if (supplier == null) {
      return const DataRow(
        cells: [
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
        ],
      );
    }

    return DataRow(
      cells: [
        DataCell(_BodyCell(supplier.name, isPrimary: true)),
        DataCell(_BodyCell(supplier.nif)),
        DataCell(_BodyCell(supplier.address)),
        DataCell(_BodyCell(supplier.phone)),
        DataCell(_BodyCell(supplier.email)),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableActionIconButton(
                  icon: Icons.edit_rounded,
                  color: Colors.lightBlueAccent,
                  tooltip: 'Editar fornecedor',
                  onPressed: () => _editSupplier(supplier),
                ),
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Remover fornecedor',
                  onPressed: () => _removeSupplier(supplier),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (_) => AddSupplierDialog(
        onSupplierAdded: (newSupplier) async {
          final dto = SupplierCreateDto(
            name: newSupplier.name,
            nif: newSupplier.nif,
            email: newSupplier.email,
            phone: newSupplier.phone,
            address: newSupplier.address,
          );
          await ref.read(supplierNotifierProvider.notifier).createSupplier(dto);
        },
      ),
    );
  }

  void _editSupplier(SupplierResponseDto supplier) {
    showDialog(
      context: context,
      builder: (_) => EditSupplierDialog(
        supplier: supplier,
        onSupplierEdited: (editedSupplier) async {
          final dto = SupplierUpdateDto(
            name: editedSupplier.name,
            nif: editedSupplier.nif,
            email: editedSupplier.email,
            phone: editedSupplier.phone,
            address: editedSupplier.address,
          );
          await ref
              .read(supplierNotifierProvider.notifier)
              .updateSupplier(supplier.id, dto);
        },
      ),
    );
  }

  void _removeSupplier(SupplierResponseDto supplier) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => RemoveSupplierDialog(
        supplier: supplier,
        onConfirmed: () async {
          await ref
              .read(supplierNotifierProvider.notifier)
              .deleteSupplier(supplier.id);
        },
      ),
    );
  }

  String _sortLabel(_SupplierSort value) {
    switch (value) {
      case _SupplierSort.nameAsc:
        return 'Nome ascendente';
      case _SupplierSort.nameDesc:
        return 'Nome descendente';
      case _SupplierSort.nifAsc:
        return 'NIF ascendente';
      case _SupplierSort.nifDesc:
        return 'NIF descendente';
    }
  }
}

enum _SupplierSort {
  nameAsc,
  nameDesc,
  nifAsc,
  nifDesc,
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String value;
  final bool isPrimary;

  const _BodyCell(this.value, {this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPrimary
              ? AppTheme.textPrimaryColor
              : AppTheme.textSecondaryColor,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(height: 20),
    );
  }
}
