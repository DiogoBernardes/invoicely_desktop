import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors/error_message_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dto/company/company_response_dto.dart';
import '../../data/dto/expense/expense_response_dto.dart';
import '../../data/dto/supplier/supplier_response_dto.dart';
import '../../providers/company_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/dialogs/custom_dialog.dart';
import '../../widgets/global_app_bar.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expenseAsync = ref.watch(expenseByIdProvider(expenseId));
    final companyAsync = ref.watch(companyNotifierProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_PT', symbol: 'EUR ');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GlobalAppBar(title: 'Despesas'),
      body: expenseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            ErrorMessageUtils.fromObject(
              e,
              fallback: 'Erro ao carregar despesa.',
            ),
          ),
        ),
        data: (expense) {
          final supplierAsync =
              ref.watch(supplierByIdProvider(expense.entityId));

          return Column(
            children: [
              _buildExpenseHeader(context, theme, expense, companyAsync),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSupplierInfo(theme, supplierAsync),
                      const SizedBox(height: 30),
                      _buildExpenseInfoTable(theme, expense, currencyFormat),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButtons(context, ref, expense),
                          _buildTotalsBox(theme, expense, currencyFormat),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpenseHeader(
    BuildContext context,
    ThemeData theme,
    ExpenseResponseDto expense,
    AsyncValue<CompanyResponseDTO?> companyAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 70),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              companyAsync.when(
                data: (company) {
                  final companyName = company?.name ?? 'COMPANY NAME';
                  return Text(
                    companyName,
                    style: theme.textTheme.headlineMedium!.copyWith(
                      fontSize: 24,
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text(
                  'COMPANY NAME',
                  style: theme.textTheme.headlineMedium!.copyWith(
                    fontSize: 24,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfoField(theme, 'Nº Despesa',
                        '#${expense.referenceCode ?? expense.id}'),
                    const SizedBox(height: 2),
                    _buildHeaderInfoField(
                      theme,
                      'Data',
                      DateFormat('dd/MM/yyyy').format(expense.date),
                    ),
                    _buildHeaderInfoField(
                      theme,
                      'Categoria',
                      expense.category.name,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: AppTheme.textPrimaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoField(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierInfo(
    ThemeData theme,
    AsyncValue<SupplierResponseDto> supplierAsync,
  ) {
    return supplierAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Text(
          ErrorMessageUtils.fromObject(
            e,
            fallback: 'Erro ao carregar fornecedor.',
          ),
        ),
      ),
      data: (supplier) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 36, 54, 71),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informacao Fornecedor',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: AppTheme.borderColor),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoLine(theme, 'Nome', supplier.name),
                        const SizedBox(height: 10),
                        _buildInfoLine(theme, 'NIF', supplier.nif),
                        const SizedBox(height: 10),
                        _buildInfoLine(theme, 'Endereco', supplier.address),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoLine(theme, 'Email', supplier.email),
                        const SizedBox(height: 10),
                        _buildInfoLine(theme, 'Telefone', supplier.phone),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoLine(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyLarge!.copyWith(
            color: const Color.fromARGB(255, 204, 204, 204),
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseInfoTable(
    ThemeData theme,
    ExpenseResponseDto expense,
    NumberFormat currencyFormat,
  ) {
    const Color tableHeaderColor = Color.fromARGB(255, 36, 54, 71);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          color: tableHeaderColor,
          child: const Row(
            children: [
              _HeaderCell('Descricao', flex: 4),
              _HeaderCell('Metodo Pagamento', flex: 3),
              _HeaderCell('Valor', flex: 2, align: TextAlign.end),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      expense.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      expense.paymentMethod.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currencyFormat.format(expense.value),
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10,
                color: AppTheme.borderColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsBox(
    ThemeData theme,
    ExpenseResponseDto expense,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 36, 54, 71),
      ),
      child: Column(
        children: [
          _totalRow('Categoria', expense.category.name),
          _totalRow(
            'Movimento Stock',
            expense.stockItemName == null
                ? 'Sem reposicao'
                : '${expense.stockItemName} (+${(expense.stockQuantity ?? 0).toStringAsFixed(2)})',
          ),
          _totalRow(
            'Comprovativo',
            expense.fileUrl == null || expense.fileUrl!.isEmpty
                ? 'Nao anexado'
                : 'Anexado',
          ),
          Divider(
            color: const Color.fromARGB(255, 197, 196, 196).withOpacity(0.5),
          ),
          _totalRow(
            'TOTAL DESPESA',
            currencyFormat.format(expense.value),
            bold: true,
            fontSize: 18,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    String label,
    String value, {
    bool bold = false,
    double fontSize = 16,
    Color? color,
  }) {
    final finalColor = color ?? Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: finalColor.withOpacity(0.9),
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: finalColor,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ExpenseResponseDto expense,
  ) {
    Future<void> showInfoDialog(String title, String message) async {
      return showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: title,
          content: Text(message, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
          maxWidthFactor: 0.4,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240,
          child: ElevatedButton.icon(
            icon:
                const Icon(Icons.visibility, color: AppTheme.textPrimaryColor),
            onPressed: () async {
              if (expense.fileUrl == null || expense.fileUrl!.isEmpty) {
                await showInfoDialog(
                  'Sem comprovativo',
                  'Esta despesa nao tem ficheiro anexado.',
                );
                return;
              }
              try {
                await ref.read(expenseNotifierProvider.notifier).openAttachment(
                      expense.id,
                      fallbackName:
                          'expense_${expense.referenceCode ?? expense.id}',
                    );
              } catch (e) {
                await showInfoDialog(
                  'Erro',
                  ErrorMessageUtils.fromObject(
                    e,
                    fallback: 'Erro ao abrir comprovativo.',
                  ),
                );
              }
            },
            label: const Text(
              'Ver Comprovativo',
              style: TextStyle(color: AppTheme.textPrimaryColor),
            ),
            style: _buttonStyle(),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 36, 54, 71),
      padding: const EdgeInsets.symmetric(vertical: 12),
      elevation: 0,
      side: BorderSide(
        color: AppTheme.textPrimaryColor.withOpacity(0.5),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const _HeaderCell(this.text,
      {required this.flex, this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
