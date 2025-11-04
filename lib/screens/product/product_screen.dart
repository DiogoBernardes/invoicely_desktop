import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoicely_desktop/data/dto/product/product_update_dto.dart';
import 'package:invoicely_desktop/widgets/dialogs/products/add_product_dialog.dart';
import 'package:invoicely_desktop/widgets/dialogs/products/edit_product_dialog.dart';
import 'package:invoicely_desktop/widgets/dialogs/products/remove_product_dialog.dart';
import '../../data/dto/product/product_create_dto.dart';
import '../../data/dto/product/product_response_dto.dart';
import '../../providers/client_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/global_app_bar.dart';
import 'package:intl/intl.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';
  final currencyFormat = NumberFormat.currency(locale: 'pt_PT', symbol: '€');
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Products'),
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
                  'Products',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Adicionar Produto',
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
                hintText: 'Pesquisar por nome, descrição, preço...',
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
              child: productsAsync.when(
                data: (products) {
                  final filtered = products
                      .where((c) =>
                          c.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          c.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          c.price
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();

                  final totalRows = _rowsPerPage;
                  final totalPages = (filtered.length / _rowsPerPage).ceil();
                  final startIndex = _currentPage * _rowsPerPage;
                  final endIndex = startIndex + _rowsPerPage;
                  final pageProducts = filtered.sublist(
                    startIndex,
                    endIndex > filtered.length ? filtered.length : endIndex,
                  );

                  // sempre 10 linhas
                  final displayProducts = List.generate(
                      totalRows,
                      (index) => index < pageProducts.length
                          ? pageProducts[index]
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
                                  'Descrição',
                                  'Preço',
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
                              rows: displayProducts.map((product) {
                                if (product == null) {
                                  return DataRow(
                                    cells: List.generate(
                                      4,
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
                                      child: Text(product.name,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(product.description,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    )),
                                    DataCell(Container(
                                      padding: cellPadding,
                                      child: Text(
                                        currencyFormat.format(product.price),
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 18),
                                            onPressed: () =>
                                                _editProduct(product),
                                            color: Colors.blue.shade400),
                                        IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 18),
                                            onPressed: () =>
                                                _removeProduct(product),
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
                    Center(child: Text('Erro ao carregar Produtos: $e')),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (_) => AddProductDialog(
        onProductAdded: (newProduct) async {
          final dto = ProductCreateDTO(
            name: newProduct.name,
            description: newProduct.description,
            price: newProduct.price,
          );
          await ref.read(productNotifierProvider.notifier).createProduct(dto);
        },
      ),
    );
  }

  void _editProduct(ProductResponseDTO product) {
    showDialog(
      context: context,
      builder: (_) => EditProductDialog(
        product: product,
        onProductUpdated: (editedProduct) async {
          final dto = ProductUpdateDTO(
            name: editedProduct.name,
            description: editedProduct.description,
            price: editedProduct.price,
          );
          await ref
              .read(productNotifierProvider.notifier)
              .updateProduct(product.id, dto);
        },
      ),
    );
  }

  void _removeProduct(ProductResponseDTO product) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => RemoveProductDialog(
        product: product,
        onConfirmed: () async {
          await ref
              .read(productNotifierProvider.notifier)
              .deleteProduct(product.id);
        },
      ),
    );
  }
}
