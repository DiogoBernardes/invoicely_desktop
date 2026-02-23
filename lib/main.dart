import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';

import 'data/services/auth_service.dart';
import 'notifiers/login_notifier.dart';
import 'providers/login_provider.dart';
import 'screens/login/login_screen.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: "Invoicely",
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    size: Size(1280, 800),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

  final loginNotifier = LoginNotifier(AuthService());
  await loginNotifier.tryAutoLogin();

  runApp(
    ProviderScope(
      overrides: [
        loginProvider.overrideWith((ref) => loginNotifier),
      ],
      child: const InvoicelyApp(),
    ),
  );
}

class InvoicelyApp extends StatelessWidget {
  const InvoicelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoicely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.appBackgroundGradient,
              ),
            ),
            const _AmbientLayer(),
            if (child != null) child,
          ],
        );
      },
      home: const LoginScreen(),
    );
  }
}

class _AmbientLayer extends StatelessWidget {
  const _AmbientLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -110,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3A8DFF).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1CC8A0).withOpacity(0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
