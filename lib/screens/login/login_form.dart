import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/login_state.dart';
import '../../providers/login_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadSavedCredentials);
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');

    if (remember && email != null && password != null) {
      setState(() {
        _rememberMe = true;
        emailController.text = email;
        passwordController.text = password;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width < 900 ? width * 0.82 : 460.0;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.panelColor.withOpacity(0.92),
                  AppTheme.panelColorSoft.withOpacity(0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.24),
                  blurRadius: 26,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A8DFF), Color(0xFF2A6BCE)],
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'windows/runner/resources/app_icon-256x256.ico',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo',
                          style: GoogleFonts.sora(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Entre para continuar',
                          style: GoogleFonts.sora(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Insira o seu email',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Insira a sua password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondaryColor,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lembrar-me',
                      style: GoogleFonts.sora(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: loginState.status == LoginStatus.loading
                        ? null
                        : () {
                            ref.read(loginProvider.notifier).login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  rememberMe: _rememberMe,
                                );
                          },
                    child: loginState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                ),
                if (loginState.isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      loginState.errorMessage ?? '',
                      style: GoogleFonts.sora(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
