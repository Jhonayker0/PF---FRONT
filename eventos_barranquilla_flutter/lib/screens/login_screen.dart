import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/FondoLogin.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Logo
                        Image.asset(
                          'assets/CumbeLogo.png',
                          width: 210,
                          height: 160,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Vive lo que pasa',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email input
                        TextField(
                          controller: _emailController,
                          enabled: !authProvider.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Correo electrónico',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Color(0xFF999999)),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password input
                        TextField(
                          controller: _passwordController,
                          enabled: !authProvider.isLoading,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Color(0xFF999999)),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login button or loader
                        if (authProvider.isLoading)
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(0xFFce1126)),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFce1126),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (_emailController.text.isEmpty ||
                                    _passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Por favor completa todos los campos',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final success = await authProvider.signIn(
                                  _emailController.text,
                                  _passwordController.text,
                                );

                                if (success && mounted) {
                                  context.go('/home');
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        authProvider.errorMessage ??
                                            'Error al iniciar sesión',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Register link
                        TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => context.go('/register'),
                          child: const Text(
                            '¿No tienes cuenta? Regístrate',
                            style: TextStyle(color: Color(0xFFCE1126)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Demo credentials
                        const Text(
                          'Cuentas demo:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  _emailController.text =
                                      'cliente@example.com';
                                  _passwordController.text = '123456';
                                },
                          child: const Text(
                            'Cliente: cliente@example.com / 123456',
                            style: TextStyle(color: Color(0xFF666666)),
                          ),
                        ),
                        TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  _emailController.text = 'admin@example.com';
                                  _passwordController.text = '123456';
                                },
                          child: const Text(
                            'Admin: admin@example.com / 123456',
                            style: TextStyle(color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
