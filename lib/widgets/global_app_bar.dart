import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../data/services/auth_service.dart';
import '../providers/login_provider.dart';
import '../providers/menu_provider.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/client/client_screen.dart';
import '../screens/company/company_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/expense/expense_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/product/product_screen.dart';
import '../screens/service/service_screen.dart';
import '../screens/supplier/supplier_screen.dart';
import 'dialogs/auth/change_password_dialog.dart';
import 'dialogs/logoutDialog.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GlobalAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 980;

    return AppBar(
      toolbarHeight: 76,
      titleSpacing: 18,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.textPrimaryColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (isMobile) const SizedBox(width: 6),
          _BrandBadge(pageTitle: title),
          if (!isMobile) ...[
            const SizedBox(width: 18),
            const Expanded(child: _NavMenu()),
          ],
        ],
      ),
      actions: [
        if (!isMobile) const _HeaderInfo(),
        const SizedBox(width: 8),
        const _UserMenu(),
        const SizedBox(width: 12),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.panelColor.withOpacity(0.96),
              AppTheme.panelColorSoft.withOpacity(0.9),
            ],
          ),
          border: Border(
            bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.75)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}

class _BrandBadge extends StatelessWidget {
  final String pageTitle;

  const _BrandBadge({required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              colors: [Color(0xFF3A8DFF), Color(0xFF2A6BCE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset('windows/runner/resources/app_icon-256x256.ico'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invoicely',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              pageTitle,
              style: GoogleFonts.sora(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GlobalDrawer extends StatelessWidget {
  const GlobalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = {
      'Dashboard': const DashboardScreen(),
      'Clientes': const ClientScreen(),
      'Fornecedores': const SupplierScreen(),
      'Produtos': const ProductScreen(),
      'Servicos': const ServiceScreen(),
      'Orcamento': const BudgetScreen(),
      'Despesas': const ExpenseScreen(),
    };

    return Drawer(
      backgroundColor: AppTheme.panelColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.panelColorSoft.withOpacity(0.9),
                  AppTheme.panelColor.withOpacity(0.95),
                ],
              ),
              border: Border(
                bottom:
                    BorderSide(color: AppTheme.borderColor.withOpacity(0.8)),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Navegacao',
                style: GoogleFonts.sora(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ...items.entries.map(
            (entry) => ListTile(
              title: Text(
                entry.key,
                style: GoogleFonts.sora(color: AppTheme.textPrimaryColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateWithTransition(context, entry.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavMenu extends ConsumerWidget {
  const _NavMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider);

    final routes = {
      'Dashboard': const DashboardScreen(),
      'Clientes': const ClientScreen(),
      'Fornecedores': const SupplierScreen(),
      'Produtos': const ProductScreen(),
      'Servicos': const ServiceScreen(),
      'Orcamento': const BudgetScreen(),
      'Despesas': const ExpenseScreen(),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: routes.keys.map((item) {
          final isSelected = selected == item;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                ref.read(selectedMenuProvider.notifier).state = item;
                if (!isSelected) {
                  _navigateWithTransition(context, routes[item]!);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.17)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.55)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.sora(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                    color: isSelected
                        ? AppTheme.textPrimaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = DateFormat('dd/MM/yyyy').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.panelColorSoft.withOpacity(0.85),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            dateLabel,
            style: GoogleFonts.sora(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3A8DFF), Color(0xFF1CC8A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          offset: const Offset(0, 6),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppTheme.panelColorSoft,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondaryColor,
          ),
          onSelected: (value) async {
            switch (value) {
              case 'Dados Empresa':
                _navigateWithTransition(context, const CompanyScreen());
                break;
              case 'Alterar Password':
                showDialog(
                  context: context,
                  builder: (_) => const ChangePasswordDialog(),
                );
                break;
              case 'Logout':
                showDialog(
                  context: context,
                  builder: (_) => LogoutDialog(
                    onConfirmed: () async {
                      final authService = AuthService();
                      await authService.logout();
                      await ref.read(loginProvider.notifier).logout();

                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          _createFadeRoute(const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Dados Empresa',
              child: Text(
                'Dados Empresa',
                style: GoogleFonts.sora(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 13,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'Alterar Password',
              child: Text(
                'Alterar Password',
                style: GoogleFonts.sora(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 13,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'Logout',
              child: Text(
                'Logout',
                style: GoogleFonts.sora(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void _navigateWithTransition(BuildContext context, Widget screen) {
  Navigator.of(context).push(_createFadeRoute(screen));
}

Route _createFadeRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
