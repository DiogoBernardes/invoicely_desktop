import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/auth/login_notifier.dart';
import '../../../domain/auth/login_state.dart';

class LoginForm extends ConsumerStatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6, // 60% da largura
        constraints: const BoxConstraints(maxWidth: 450), // Largura máxima
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main title with icon behind
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image on top
                  Image.asset(
                    'windows/runner/resources/app_icon-256x256.ico',
                    width: 120,
                    height: 120,
                    //color: Color.fromARGB(30, 255, 255, 255),
                  ),
                  const SizedBox(height: 16), // Espaço entre imagem e texto
                  // Text below
                  const Text(
                    'Bem-Vindo!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Company ID or Email field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.emailController,
                decoration: const InputDecoration(
                  hintText: 'Insira o seu email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Inseria a sua password',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    // Add forgot password logic here
                  },
                  child: const Text(
                    'Esqueceu-se da Palavra passe?',
                    style: TextStyle(
                      color: Color.fromARGB(255, 145, 173, 201),
                      fontSize: 10,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  onPressed: loginState.status == LoginStatus.loading
                      ? null
                      : () {
                          ref.read(loginProvider.notifier).login(
                                widget.emailController.text.trim(),
                                widget.passwordController.text.trim(),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 18, 115, 212),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: loginState.status == LoginStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              // Error message
              if (loginState.status == LoginStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    loginState.errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
