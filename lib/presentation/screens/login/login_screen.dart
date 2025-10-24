import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/auth/login_notifier.dart';
import '../../../domain/auth/login_state.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);

    // Navegação automática quando login for sucesso
    if (loginState.status == LoginStatus.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      });
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LoginForm(
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
          ),
        ),
      ),
    );
  }
}
