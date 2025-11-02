import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/menu_provider.dart';
import '../screens/client/client_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

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
          // Logo + Texto "Invoicely"
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

          // Menu desktop ou botão drawer mobile
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
        _SearchField(),
        SizedBox(width: 16),
        _UserMenu(),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

// Drawer mobile
class GlobalDrawer extends StatelessWidget {
  const GlobalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = {
      'Dashboard': const DashboardScreen(),
      'Clients': const ClientScreen(),
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
                Navigator.pop(context); // fecha o Drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => entry.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Menu de navegação desktop
class _NavMenu extends ConsumerWidget {
  const _NavMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider);

    final routes = {
      'Dashboard': const DashboardScreen(),
      'Clients': const ClientScreen(),
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
              // Atualiza a seleção
              ref.read(selectedMenuProvider.notifier).state = item;

              // Navega só se não for a página atual
              if (!isSelected) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => routes[item]!),
                );
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
                    color: isSelected
                        ? const Color.fromARGB(255, 129, 183, 245)
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
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

// Campo de pesquisa
class _SearchField extends StatelessWidget {
  const _SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1A2633);

    return Container(
      width: 200,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                ),
              ),
              child: const TextField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
                cursorColor: Colors.white70,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Avatar do utilizador com dropdown
class _UserMenu extends StatelessWidget {
  const _UserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
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
        // Seta dropdown estilizada
        PopupMenuButton<String>(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          color: const Color.fromARGB(255, 26, 38, 51),
          elevation: 8,
          offset: const Offset(0, 50), // abre logo abaixo do avatar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'Dados Empresa':
                // Navegar para página de dados da empresa
                break;
              case 'Logout':
                // Implementar logout
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
