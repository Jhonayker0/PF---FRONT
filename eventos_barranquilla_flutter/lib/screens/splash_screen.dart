import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9F4EB), Color(0xFFF1E6D9)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 104,
                width: 104,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 22,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🎭',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Eventos Barranquilla',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181818),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Descubre, guarda y vive la ciudad',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B645C),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
