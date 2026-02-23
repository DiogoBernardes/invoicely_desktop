import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class TablePageShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> actions;
  final Widget filters;
  final Widget content;

  const TablePageShell({
    super.key,
    required this.title,
    required this.icon,
    required this.actions,
    required this.filters,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 1100;
        final horizontalPadding = compact ? 24.0 : 56.0;
        final verticalPadding = compact ? 24.0 : 36.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                spacing: 12,
                children: [
                  _TitleBlock(title: title, icon: icon),
                  Wrap(spacing: 10, runSpacing: 10, children: actions),
                ],
              ),
              const SizedBox(height: 20),
              GlassPanel(child: filters),
              const SizedBox(height: 20),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.82)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.panelColor.withOpacity(0.94),
            AppTheme.panelColorSoft.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppTableContainer extends StatelessWidget {
  final Widget child;

  const AppTableContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(0),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
  }
}

class TableSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final double? width;

  const TableSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close, size: 18),
              ),
      ),
    );

    if (width == null) {
      return field;
    }
    return SizedBox(width: width, child: field);
  }
}

class TablePaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const TablePaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.panelColorSoft.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.7)),
          ),
          child: Text(
            'Pagina $currentPage de $totalPages',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _PaginationButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onPressed: onPrevious,
        ),
        _PaginationButton(
          icon: Icons.keyboard_arrow_right_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class TableActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const TableActionIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.45)),
        ),
        child: IconButton(
          iconSize: 18,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          splashRadius: 18,
          onPressed: onPressed,
          icon: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final IconData icon;

  const _TitleBlock({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.38)),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: AppTheme.panelColorSoft.withOpacity(0.74),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.72)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 20,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      ),
    );
  }
}
