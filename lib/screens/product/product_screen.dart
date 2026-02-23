import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/product/product_create_dto.dart';
import '../../data/dto/product/product_response_dto.dart';
import '../../data/dto/product/product_update_dto.dart';
import '../../providers/product_provider.dart';
import '../../widgets/dialogs/products/add_product_dialog.dart';
import '../../widgets/dialogs/products/edit_product_dialog.dart';
import '../../widgets/dialogs/products/remove_product_dialog.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/ui/table_ui.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  String _searchQuery = '';
  bool _showOnlyLowStock = false;
  _ProductSort _sort = _ProductSort.nameAsc;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_PT', symbol: 'EUR ');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Produtos'),
      drawer: const GlobalDrawer(),
      body: TablePageShell(
        title: 'Produtos',
        icon: Icons.shopping_bag_rounded,
        actions: [
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(productNotifierProvider.notifier).loadProducts(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Atualizar'),
          ),
          ElevatedButton.icon(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo Produto'),
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
              child: DropdownButtonFormField<_ProductSort>(
                value: _sort,
                decoration: const InputDecoration(
                  labelText: 'Ordenar',
                  prefixIcon: Icon(Icons.swap_vert_rounded, size: 18),
                ),
                items: _ProductSort.values
                    .map(
                      (value) => DropdownMenuItem<_ProductSort>(
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
            const SizedBox(width: 12),
            FilterChip(
              selected: _showOnlyLowStock,
              label: const Text('Baixo stock'),
              onSelected: (value) {
                setState(() {
                  _showOnlyLowStock = value;
                  _currentPage = 0;
                });
              },
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(width: 12),
              _activeFilterPill(),
            ],
          ],
        ),
        content: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(
              ErrorMessageUtils.fromObject(
                e,
                fallback: 'Erro ao carregar produtos.',
              ),
            ),
          ),
          data: (products) => _buildTableContent(products),
        ),
      ),
    );
  }

  Widget _buildTableContent(List<ProductResponseDTO> products) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.price.toString().contains(query) ||
          product.stockQuantity.toString().contains(query);
      final matchesStockFilter = !_showOnlyLowStock || product.lowStock;
      return matchesSearch && matchesStockFilter;
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _ProductSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _ProductSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _ProductSort.priceAsc:
          return a.price.compareTo(b.price);
        case _ProductSort.priceDesc:
          return b.price.compareTo(a.price);
        case _ProductSort.stockAsc:
          return a.stockQuantity.compareTo(b.stockQuantity);
        case _ProductSort.stockDesc:
          return b.stockQuantity.compareTo(a.stockQuantity);
      }
    });

    final totalPages = ((filtered.length + _rowsPerPage - 1) / _rowsPerPage)
        .floor()
        .clamp(1, 999999);
    final effectivePage = _currentPage.clamp(0, totalPages - 1);
    final startIndex = effectivePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    final pageProducts = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <ProductResponseDTO>[];
    final displayProducts = List<ProductResponseDTO?>.generate(
      _rowsPerPage,
      (index) => index < pageProducts.length ? pageProducts[index] : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppTableContainer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = max(constraints.maxWidth, 980.0);
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
                          label: _HeaderCell('Stock'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Stock Min'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Estado'),
                        ),
                        DataColumn(
                          label: _HeaderCell('Acoes'),
                        ),
                      ],
                      rows: displayProducts
                          .map((product) => _buildRow(product))
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

  DataRow _buildRow(ProductResponseDTO? product) {
    if (product == null) {
      return const DataRow(
        cells: [
          DataCell(_EmptyCell()),
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
        DataCell(_BodyCell(product.name, isPrimary: true)),
        DataCell(_BodyCell(product.description)),
        DataCell(_BodyCell(_currencyFormat.format(product.price))),
        DataCell(_BodyCell(product.stockQuantity.toStringAsFixed(2))),
        DataCell(_BodyCell(product.minimumStock.toStringAsFixed(2))),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _StockStatusBadge(lowStock: product.lowStock),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableActionIconButton(
                  icon: Icons.edit_rounded,
                  color: Colors.lightBlueAccent,
                  tooltip: 'Editar produto',
                  onPressed: () => _editProduct(product),
                ),
                const SizedBox(width: 8),
                TableActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Remover produto',
                  onPressed: () => _removeProduct(product),
                ),
              ],
            ),
          ),
        ),
      ],
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
            stockQuantity: newProduct.stockQuantity,
            minimumStock: newProduct.minimumStock,
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
            stockQuantity: editedProduct.stockQuantity,
            minimumStock: editedProduct.minimumStock,
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

  String _sortLabel(_ProductSort value) {
    switch (value) {
      case _ProductSort.nameAsc:
        return 'Nome ascendente';
      case _ProductSort.nameDesc:
        return 'Nome descendente';
      case _ProductSort.priceAsc:
        return 'Preco ascendente';
      case _ProductSort.priceDesc:
        return 'Preco descendente';
      case _ProductSort.stockAsc:
        return 'Stock ascendente';
      case _ProductSort.stockDesc:
        return 'Stock descendente';
    }
  }
}

enum _ProductSort {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc,
}

class _StockStatusBadge extends StatelessWidget {
  final bool lowStock;

  const _StockStatusBadge({required this.lowStock});

  @override
  Widget build(BuildContext context) {
    final tone = lowStock ? Colors.orangeAccent : Colors.greenAccent;
    final label = lowStock ? 'Baixo' : 'OK';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
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
