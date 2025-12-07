import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invoicely_desktop/providers/client_provider.dart';
import 'package:invoicely_desktop/providers/company_provider.dart';
import '../../data/dto/budget/budget_response_dto.dart';
import '../../data/dto/client/client_response_dto.dart';
import '../../data/dto/company/company_response_dto.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/dialogs/custom_dialog.dart';
import '../../widgets/global_app_bar.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final String budgetId;

  const BudgetDetailScreen({super.key, required this.budgetId});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE':
        return const Color.fromARGB(255, 255, 179, 0);
      case 'ACEITE':
        return const Color.fromARGB(255, 0, 128, 0);
      case 'REJEITADO':
        return Colors.red;
      default:
        return AppTheme.textPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetsAsync = ref.watch(budgetNotifierProvider);
    final companyAsync = ref.watch(companyNotifierProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GlobalAppBar(title: 'Orçamentos'),
      body: budgetsAsync.when(
        data: (budgets) {
          final budget = budgets.firstWhere((b) => b.id == budgetId);
          double subTotal = budget.items.fold(0, (sum, item) {
            final itemTotal = item.unitPrice * item.quantity;
            final itemIva = itemTotal * (item.iva / 100);
            return sum + itemTotal + itemIva;
          });

          final double totalRetirado = subTotal - budget.total;
          final double totalFinal = budget.total;
          final client = ref.watch(clientByIdProvider(budget.entityId));

          return Column(
            children: [
              // --- Header do Budget ---
              _buildBudgetHeader(context, theme, budget, ref, companyAsync),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Informações do Cliente ---
                      _buildClientInfo(context, theme, budget, client),
                      const SizedBox(height: 30),
                      // --- Tabela de Itens ---
                      _buildItemsTable(context, theme, budget, currencyFormat),
                      const SizedBox(height: 30),
                      // --- Totais e Botões de Ação na mesma Row ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botões de Ação
                          _buildActionButtons(context, ref, budget),
                          // Totais
                          _buildTotalsBox(
                              context,
                              theme,
                              currencyFormat,
                              subTotal,
                              budget.discount,
                              totalRetirado,
                              totalFinal),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar budget: $e')),
      ),
    );
  }

  // --- HEADER COM NOME DA EMPRESA
  Widget _buildBudgetHeader(
      BuildContext context,
      ThemeData theme,
      BudgetResponseDTO budget,
      WidgetRef ref,
      AsyncValue<CompanyResponseDTO?> companyAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 70),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              companyAsync.when(
                data: (company) {
                  final companyName = company?.name ?? "COMPANY NAME";
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
                error: (err, _) => Text("COMPANY NAME",
                    style: theme.textTheme.headlineMedium!.copyWith(
                        fontSize: 24, color: AppTheme.textPrimaryColor)),
              ),
              const Spacer(),
              SizedBox(
                width: 175,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfoField(
                        theme, "Nº Orçamento", "#${budget.id}",
                        isBudgetID: true),
                    const SizedBox(height: 2),
                    _buildHeaderInfoField(theme, "Data",
                        DateFormat('dd/MM/yyyy').format(budget.date)),
                    _buildHeaderInfoField(theme, "Estado", budget.state,
                        isStatus: true),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          // Sublinhado subtil
          Container(
            height: 1,
            color: AppTheme.textPrimaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoField(ThemeData theme, String label, String value,
      {bool isStatus = false, bool isBudgetID = false}) {
    final Color statusColor =
        isStatus ? _getStatusColor(value) : AppTheme.textPrimaryColor;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ",
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
                color: statusColor,
                fontWeight:
                    isStatus || isBudgetID ? FontWeight.bold : FontWeight.w600,
              ),
              overflow: isBudgetID ? TextOverflow.ellipsis : null,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // --- CLIENT INFO ---
  Widget _buildClientInfo(BuildContext context, ThemeData theme,
      BudgetResponseDTO budget, AsyncValue<ClientResponseDTO> clientAsync) {
    return clientAsync.when(
      data: (client) {
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
                "Informação Cliente",
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
                        _buildInfoLine(
                            theme, "Nome Cliente", budget.entityName),
                        const SizedBox(height: 10),
                        _buildInfoLine(theme, "NIF", client.nif),
                        const SizedBox(height: 10),
                        _buildInfoLine(theme, "Endereço", client.address),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoLine(theme, "Email", client.email),
                        const SizedBox(height: 10),
                        _buildInfoLine(theme, "Telefone", client.phone),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erro ao carregar cliente: $e')),
    );
  }

  Widget _buildInfoLine(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
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

  // --- ITENS TABLE ---
  Widget _buildItemsTable(BuildContext context, ThemeData theme,
      BudgetResponseDTO budget, NumberFormat currencyFormat) {
    const Color tableHeaderColor = Color.fromARGB(255, 36, 54, 71);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          color: tableHeaderColor,
          child: Row(
            children: [
              _buildTableHeader("Item", flex: 3),
              _buildTableHeader("Preço Unit.", flex: 2, align: TextAlign.end),
              _buildTableHeader("IVA", flex: 2, align: TextAlign.end),
              _buildTableHeader("Quantidade", flex: 2, align: TextAlign.end),
              _buildTableHeader("Total", flex: 2, align: TextAlign.end),
            ],
          ),
        ),
        ...budget.items.map((item) {
          double ivaDisplay = item.iva;
          double itemTotal = item.totalWithIva;

          String formattedQuantity = item.quantity == item.quantity.toInt()
              ? item.quantity.toInt().toString()
              : item.quantity.toStringAsFixed(2);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(item.itemName,
                            style: theme.textTheme.bodyMedium)),
                    Expanded(
                        flex: 2,
                        child: Text(currencyFormat.format(item.unitPrice),
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium)),
                    Expanded(
                        flex: 2,
                        child: Text('${ivaDisplay.toStringAsFixed(0)}%',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium)),
                    Expanded(
                        flex: 2,
                        child: Text(formattedQuantity,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium)),
                    Expanded(
                        flex: 2,
                        child: Text(currencyFormat.format(itemTotal),
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor))),
                  ],
                ),
                Divider(
                    height: 10, color: AppTheme.borderColor.withOpacity(0.5)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text,
      {required int flex, TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14),
      ),
    );
  }

  // --- TOTAIS ---
  Widget _buildTotalsBox(
      BuildContext context,
      ThemeData theme,
      NumberFormat currencyFormat,
      double subTotal,
      double discount,
      double totalRetired,
      double totalFinal) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 36, 54, 71),
      ),
      child: Column(
        children: [
          _totalRow(context, "Subtotal", currencyFormat.format(subTotal)),
          _totalRow(context, "Desconto", '${discount.toStringAsFixed(0)}%'),
          _totalRow(
              context, "Valor Retirado", currencyFormat.format(totalRetired)),
          Divider(
              color: const Color.fromARGB(255, 197, 196, 196).withOpacity(0.5)),
          _totalRow(
            context,
            "TOTAL A PAGAR",
            currencyFormat.format(totalFinal),
            bold: true,
            fontSize: 18,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, String value,
      {bool bold = false, double fontSize = 16, Color? color}) {
    final finalColor = color ?? Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  color: finalColor.withOpacity(0.9),
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  color: finalColor,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }

  // --- ACTION BUTTONS ---
  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, BudgetResponseDTO budget) {
    if (budget.state.toUpperCase() == 'REJEITADO')
      return const SizedBox.shrink();

    Future<void> _showDialog(String title, String message) async {
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
          width: 200,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download, color: AppTheme.textPrimaryColor),
            onPressed: () async {
              if (budget.pdfUrl == null || budget.pdfUrl!.isEmpty) {
                await _showDialog(
                    'Erro', 'Nenhum PDF disponível para download');
                return;
              }
              try {
                await ref
                    .read(budgetNotifierProvider.notifier)
                    .downloadPdf(budget.id);
                await _showDialog('Sucesso', 'Download realizado com sucesso');
              } catch (e) {
                await _showDialog('Erro', 'Erro ao descarregar PDF: $e');
              }
            },
            label: const Text('Download PDF',
                style: TextStyle(color: AppTheme.textPrimaryColor)),
            style: _buttonStyle(),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send, color: AppTheme.textPrimaryColor),
            onPressed: () async {
              try {
                await ref
                    .read(budgetNotifierProvider.notifier)
                    .sendToClient(budget.id);
                await _showDialog('Sucesso', 'Enviado ao cliente com sucesso');
              } catch (e) {
                await _showDialog('Erro', 'Erro ao enviar para o cliente: $e');
              }
            },
            label: const Text('Enviar Cliente',
                style: TextStyle(color: AppTheme.textPrimaryColor)),
            style: _buttonStyle(),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.email, color: AppTheme.textPrimaryColor),
            onPressed: () {
              _showSendByEmailDialog(context, ref, budget);
            },
            label: const Text('Enviar Email',
                style: TextStyle(color: AppTheme.textPrimaryColor)),
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
          color: AppTheme.textPrimaryColor.withOpacity(0.5), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  // --- ENVIAR EMAIL DIALOG ---
  Future<void> _showSendByEmailDialog(
      BuildContext context, WidgetRef ref, BudgetResponseDTO budget) async {
    final formKey = GlobalKey<FormState>();
    String? clientEmail;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 36, 54, 71),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Enviar Orçamento por Email',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Insira o endereço de email:',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSaved: (value) => clientEmail = value,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Por favor, insira um email.';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  try {
                    await ref
                        .read(budgetNotifierProvider.notifier)
                        .sendByEmail(budget.id, clientEmail!);
                    Navigator.of(dialogContext).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao enviar: $e')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
