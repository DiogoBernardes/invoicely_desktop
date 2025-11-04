import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/client/client_create_dto.dart';
import '../../data/dto/client/client_response_dto.dart';
import '../../data/dto/client/client_update_dto.dart';
import '../../providers/client_provider.dart';
import '../../widgets/dialogs/client/add_client_dialog.dart';
import '../../widgets/dialogs/client/edit_client_dialog.dart';
import '../../widgets/dialogs/client/remove_client_dialog.dart';
import '../../widgets/global_app_bar.dart';

class ClientScreen extends ConsumerStatefulWidget {
  const ClientScreen({super.key});

  @override
  ConsumerState<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends ConsumerState<ClientScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Clientes'),
      drawer: const GlobalDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clientes',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddClientDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Adicionar Cliente',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 54, 71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 48),
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, email, NIF...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color.fromARGB(221, 36, 54, 71),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 0;
                });
              },
            ),
            const SizedBox(height: 32),
            // Table
            Expanded(
              child: clientsAsync.when(
                data: (clients) {
                  final filtered = clients
                      .where((c) =>
                          c.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          c.email
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          c.nif
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();

                  final totalRows = _rowsPerPage;
                  final totalPages = (filtered.length / _rowsPerPage).ceil();
                  final startIndex = _currentPage * _rowsPerPage;
                  final endIndex = startIndex + _rowsPerPage;
                  final pageClients = filtered.sublist(
                    startIndex,
                    endIndex > filtered.length ? filtered.length : endIndex,
                  );

                  // sempre 10 linhas
                  final displayClients = List.generate(
                      totalRows,
                      (index) => index < pageClients.length
                          ? pageClients[index]
                          : null);

                  const cellPadding =
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white70, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DataTable(
                              headingRowHeight: 56,
                              headingRowColor: WidgetStateProperty.all(
                                  const Color.fromARGB(221, 26, 38, 51)),
                              dataRowColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 36, 54, 71)),
                              columnSpacing: 0,
                              horizontalMargin: 0,
                              columns: [
                                for (final label in [
                                  'Nome',
                                  'NIF',
                                  'Endereço',
                                  'Telefone',
                                  'Email',
                                  'Ações'
                                ])
                                  DataColumn(
                                    label: Container(
                                      padding: cellPadding,
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              rows: displayClients.map((client) {
                                if (client == null) {
                                  return DataRow(
                                    cells: List.generate(
                                      6,
                                      (index) => DataCell(Container(
                                        padding: cellPadding,
                                        child: const Text(''),
                                      )),
                                    ),
                                  );
                                }

                                return DataRow(
                                  cells: [
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(client.name,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(client.nif,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(client.address,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(client.phone,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(client.email,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 18),
                                            onPressed: () =>
                                                _editClient(client),
                                            color: Colors.blue.shade400),
                                        IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 18),
                                            onPressed: () =>
                                                _removeClient(client),
                                            color: Colors.red.shade400),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                              'Página ${_currentPage + 1} de ${totalPages == 0 ? 1 : totalPages}',
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: const Icon(Icons.arrow_back_ios, size: 18),
                            color: Colors.white70,
                          ),
                          IconButton(
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            color: Colors.white70,
                          ),
                        ],
                      )
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    Center(child: Text('Erro ao carregar clientes: $e')),
              ),
            )
          ],
        ),
      ),
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
}
