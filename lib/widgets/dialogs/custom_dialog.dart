import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final double maxWidthFactor;
  final IconData? icon;
  final String? subtitle;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.maxWidthFactor = 0.52,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = (screenWidth * maxWidthFactor).clamp(320.0, 960.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor.withOpacity(0.85)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.panelColor.withOpacity(0.97),
                  AppTheme.panelColorSoft.withOpacity(0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DialogHeader(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.64,
                    ),
                    child: SingleChildScrollView(child: content),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.end,
                    runAlignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const _DialogHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tone = AppTheme.primaryColor.withOpacity(0.14);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tone,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.35)),
          ),
          child: Icon(icon ?? Icons.tune_rounded, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
