import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/services/auth_service.dart';
import '../providers/login_provider.dart';
import '../providers/menu_provider.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/client/client_screen.dart';
import '../screens/company/company_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/product/product_screen.dart';
import '../screens/service/service_screen.dart';
import '../screens/supplier/supplier_screen.dart';
import 'dialogs/logoutDialog.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GlobalAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppBar(
      backgroundColor: const Color.fromARGB(255, 26, 38, 51),
      elevation: 2,
      titleSpacing: 16,
      toolbarHeight: 64,
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Image.asset(
                  'windows/runner/resources/app_icon-256x256.ico',
                  height: 28,
                  width: 28,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  'Invoicely',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          if (!isMobile)
            const Expanded(child: _NavMenu())
          else
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.blue),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
        ],
      ),
      actions: const [
        _UserMenu(),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
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
      'Serviços': const ServiceScreen(),
      'Orçamento': const BudgetScreen(),
    };

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 1, 28, 55)),
            child: Text(
              'Invoicely',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ...items.entries.map(
            (entry) => ListTile(
              title: Text(entry.key),
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
  const _NavMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider);

    final routes = {
      'Dashboard': const DashboardScreen(),
      'Clientes': const ClientScreen(),
      'Fornecedores': const SupplierScreen(),
      'Produtos': const ProductScreen(),
      'Serviços': const ServiceScreen(),
      'Orçamento': const BudgetScreen(),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: routes.keys.map((item) {
        final isSelected = selected == item;
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              ref.read(selectedMenuProvider.notifier).state = item;

              if (!isSelected) {
                _navigateWithTransition(context, routes[item]!);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 16,
                    color: isSelected
                        ? const Color.fromARGB(255, 129, 183, 245)
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  width: isSelected ? 24 : 0,
                  color: Colors.blue[800],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: const Icon(Icons.person, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          color: const Color.fromARGB(255, 26, 38, 51),
          elevation: 8,
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'Dados Empresa':
                _navigateWithTransition(context, const CompanyScreen());
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
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'Dados Empresa',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Dados Empresa',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'Logout',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Logout',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
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
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
