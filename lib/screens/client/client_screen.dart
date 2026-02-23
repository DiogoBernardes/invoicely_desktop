import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/client/client_create_dto.dart';
import '../../data/dto/client/client_response_dto.dart';
import '../../data/dto/client/client_update_dto.dart';
import '../../providers/client_provider.dart';
import '../../widgets/dialogs/client/add_client_dialog.dart';
import '../../widgets/dialogs/client/edit_client_dialog.dart';
import '../../widgets/dialogs/client/remove_client_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';

class ClientScreen extends ConsumerStatefulWidget {
  const ClientScreen({super.key});

  @override
  ConsumerState<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends ConsumerState<ClientScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  String _searchQuery = '';
  _ClientSort _sort = _ClientSort.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Clientes'),
      drawer: const GlobalDrawer(),
      body: TablePageShell(
        title: 'Clientes',
        icon: Icons.groups_rounded,
        actions: [
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(clientNotifierProvider.notifier).loadClients(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Atualizar'),
          ),
          ElevatedButton.icon(
            onPressed: _showAddClientDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo Cliente'),
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
              child: DropdownButtonFormField<_ClientSort>(
                value: _sort,
                decoration: const InputDecoration(
                  labelText: 'Ordenar',
                  prefixIcon: Icon(Icons.swap_vert_rounded, size: 18),
                ),
                items: _ClientSort.values
                    .map(
                      (value) => DropdownMenuItem<_ClientSort>(
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
        content: clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(
              ErrorMessageUtils.fromObject(
                e,
                fallback: 'Erro ao carregar clientes.',
              ),
            ),
          ),
          data: (clients) => _buildTableContent(clients),
        ),
      ),
    );
  }

  Widget _buildTableContent(List<ClientResponseDTO> clients) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = clients.where((client) {
      return client.name.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          client.nif.toLowerCase().contains(query) ||
          client.phone.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _ClientSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _ClientSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _ClientSort.nifAsc:
          return a.nif.compareTo(b.nif);
        case _ClientSort.nifDesc:
          return b.nif.compareTo(a.nif);
      }
    });

    final totalPages = ((filtered.length + _rowsPerPage - 1) / _rowsPerPage)
        .floor()
        .clamp(1, 999999);
    final effectivePage = _currentPage.clamp(0, totalPages - 1);
    final startIndex = effectivePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    final pageClients = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <ClientResponseDTO>[];
    final displayClients = List<ClientResponseDTO?>.generate(
      _rowsPerPage,
      (index) => index < pageClients.length ? pageClients[index] : null,
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
                      rows: displayClients
                          .map((client) => _buildRow(client))
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

  DataRow _buildRow(ClientResponseDTO? client) {
    if (client == null) {
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
        DataCell(_BodyCell(client.name, isPrimary: true)),
        DataCell(_BodyCell(client.nif)),
        DataCell(_BodyCell(client.address)),
        DataCell(_BodyCell(client.phone)),
        DataCell(_BodyCell(client.email)),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableActionIconButton(
                  icon: Icons.edit_rounded,
                  color: Colors.lightBlueAccent,
                  tooltip: 'Editar cliente',
                  onPressed: () => _editClient(client),
                ),
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Remover cliente',
                  onPressed: () => _removeClient(client),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (_) => AddClientDialog(
        onClientAdded: (newClient) async {
          final dto = ClientCreateDTO(
            name: newClient.name,
            nif: newClient.nif,
            email: newClient.email,
            phone: newClient.phone,
            address: newClient.address,
          );
          await ref.read(clientNotifierProvider.notifier).createClient(dto);
        },
      ),
    );
  }

  void _editClient(ClientResponseDTO client) {
    showDialog(
      context: context,
      builder: (_) => EditClientDialog(
        client: client,
        onClientAdded: (editedClient) async {
          final dto = ClientUpdateDTO(
            name: editedClient.name,
            nif: editedClient.nif,
            email: editedClient.email,
            phone: editedClient.phone,
            address: editedClient.address,
          );
          await ref
              .read(clientNotifierProvider.notifier)
              .updateClient(client.id, dto);
        },
      ),
    );
  }

  void _removeClient(ClientResponseDTO client) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => RemoveClientDialog(
        client: client,
        onConfirmed: () async {
          await ref
              .read(clientNotifierProvider.notifier)
              .deleteClient(client.id);
        },
      ),
    );
  }

  String _sortLabel(_ClientSort value) {
    switch (value) {
      case _ClientSort.nameAsc:
        return 'Nome ascendente';
      case _ClientSort.nameDesc:
        return 'Nome descendente';
      case _ClientSort.nifAsc:
        return 'NIF ascendente';
      case _ClientSort.nifDesc:
        return 'NIF descendente';
    }
  }
}

enum _ClientSort {
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
