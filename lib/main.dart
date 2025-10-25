import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/services/auth_service.dart';
import 'notifiers/login_notifier.dart';
import 'providers/login_provider.dart';
import 'screens/login/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
      title: 'Invoicely Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
