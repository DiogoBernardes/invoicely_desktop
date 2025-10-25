import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/login_state.dart';
import '../../providers/login_provider.dart';
import '../company/company_register_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);

    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.success) {
        if (next.hasCompany) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyRegisterScreen()),
          );
        }
      }

      if (next.isError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: loginState.isLoading
            ? const CircularProgressIndicator()
            : const LoginForm(),
      ),
    );
  }
}
