import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                padding: const EdgeInsets.only(bottom: 2), // ligeiro ajuste
                child: Image.asset(
                  'windows/runner/resources/app_icon-256x256.ico',
                  height: 28,
                  width: 28,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 1), // alinha texto com menu
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
        _UserAvatar(),
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
    final items = ['Dashboard', 'Budgets', 'Clients', 'Products', 'Expenses'];

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
          ...items.map(
            (item) => ListTile(
              title: Text(item),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Menu de navegação desktop
class _NavMenu extends StatefulWidget {
  const _NavMenu({super.key});

  @override
  State<_NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<_NavMenu> {
  String selected = 'Dashboard';
  final items = ['Dashboard', 'Budgets', 'Clients', 'Products', 'Expenses'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items.map((item) {
        final isSelected = selected == item;
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent, // <-- hover desativado
            onTap: () => setState(() => selected = item),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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

// Avatar do utilizador
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: const Icon(Icons.person, color: Colors.blue, size: 20),
    );
  }
}
