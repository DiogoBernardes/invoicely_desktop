import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/service/service_create_dto.dart';
import '../../data/dto/service/service_response_dto.dart';
import '../../data/dto/service/service_update_dto.dart';
import '../../providers/service_provider.dart';
import '../../widgets/dialogs/services/add_service_dialog.dart';
import '../../widgets/dialogs/services/edit_service_dialog.dart';
import '../../widgets/dialogs/services/remove_service_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});

  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  String _searchQuery = '';
  _ServiceSort _sort = _ServiceSort.nameAsc;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_PT', symbol: 'EUR ');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Servicos'),
      drawer: const GlobalDrawer(),
      body: TablePageShell(
        title: 'Servicos',
        icon: Icons.design_services_rounded,
        actions: [
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(serviceNotifierProvider.notifier).loadServices(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Atualizar'),
          ),
          ElevatedButton.icon(
            onPressed: _showAddServiceDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo Servico'),
          ),
        ],
        filters: Row(
          children: [
            Expanded(
              child: TableSearchField(
                controller: _searchController,
                hintText: 'Pesquisar por nome, descricao ou preco',
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
              child: DropdownButtonFormField<_ServiceSort>(
                value: _sort,
                decoration: const InputDecoration(
                  labelText: 'Ordenar',
                  prefixIcon: Icon(Icons.swap_vert_rounded, size: 18),
                ),
                items: _ServiceSort.values
                    .map(
                      (value) => DropdownMenuItem<_ServiceSort>(
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
        content: servicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(
              ErrorMessageUtils.fromObject(
                e,
                fallback: 'Erro ao carregar servicos.',
              ),
            ),
          ),
          data: (services) => _buildTableContent(services),
        ),
      ),
    );
  }

  Widget _buildTableContent(List<ServiceResponseDTO> services) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = services.where((service) {
      return service.name.toLowerCase().contains(query) ||
          service.description.toLowerCase().contains(query) ||
          service.price.toString().contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _ServiceSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _ServiceSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _ServiceSort.priceAsc:
          return a.price.compareTo(b.price);
        case _ServiceSort.priceDesc:
          return b.price.compareTo(a.price);
      }
    });

    final totalPages = ((filtered.length + _rowsPerPage - 1) / _rowsPerPage)
        .floor()
        .clamp(1, 999999);
    final effectivePage = _currentPage.clamp(0, totalPages - 1);
    final startIndex = effectivePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    final pageServices = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <ServiceResponseDTO>[];
    final displayServices = List<ServiceResponseDTO?>.generate(
      _rowsPerPage,
      (index) => index < pageServices.length ? pageServices[index] : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppTableContainer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = max(constraints.maxWidth, 760.0);
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
                          label: _HeaderCell('Descricao'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Preco'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Acoes'),
                        ),
                      ],
                      rows: displayServices
                          .map((service) => _buildRow(service))
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

  DataRow _buildRow(ServiceResponseDTO? service) {
    if (service == null) {
      return const DataRow(
        cells: [
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
          DataCell(_EmptyCell()),
        ],
      );
    }

    return DataRow(
      cells: [
        DataCell(_BodyCell(service.name, isPrimary: true)),
        DataCell(_BodyCell(service.description)),
        DataCell(_BodyCell(_currencyFormat.format(service.price))),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableActionIconButton(
                  icon: Icons.edit_rounded,
                  color: Colors.lightBlueAccent,
                  tooltip: 'Editar servico',
                  onPressed: () => _editService(service),
                ),
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Remover servico',
                  onPressed: () => _removeService(service),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (_) => AddServiceDialog(
        onServiceAdded: (newService) async {
          final dto = ServiceCreateDTO(
            name: newService.name,
            description: newService.description,
            price: newService.price,
          );
          await ref.read(serviceNotifierProvider.notifier).createService(dto);
        },
      ),
    );
  }

  void _editService(ServiceResponseDTO service) {
    showDialog(
      context: context,
      builder: (_) => EditServiceDialog(
        service: service,
        onServiceUpdated: (editedService) async {
          final dto = ServiceUpdateDTO(
            name: editedService.name,
            description: editedService.description,
            price: editedService.price,
          );
          await ref
              .read(serviceNotifierProvider.notifier)
              .updateService(service.id, dto);
        },
      ),
    );
  }

  void _removeService(ServiceResponseDTO service) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => RemoveServiceDialog(
        service: service,
        onConfirmed: () async {
          await ref
              .read(serviceNotifierProvider.notifier)
              .deleteService(service.id);
        },
      ),
    );
  }

  String _sortLabel(_ServiceSort value) {
    switch (value) {
      case _ServiceSort.nameAsc:
        return 'Nome ascendente';
      case _ServiceSort.nameDesc:
        return 'Nome descendente';
      case _ServiceSort.priceAsc:
        return 'Preco ascendente';
      case _ServiceSort.priceDesc:
        return 'Preco descendente';
    }
  }
}

enum _ServiceSort {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
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
