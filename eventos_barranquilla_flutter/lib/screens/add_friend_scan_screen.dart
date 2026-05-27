import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class AddFriendScanScreen extends StatefulWidget {
  const AddFriendScanScreen({super.key});

  @override
  State<AddFriendScanScreen> createState() => _AddFriendScanScreenState();
}

class _AddFriendScanScreenState extends State<AddFriendScanScreen> {
  final UserService _userService = UserService();
  bool _isProcessing = false;

  Future<void> _handleScan(String scannedId) async {
    if (_isProcessing) {
      return;
    }

    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesion para agregar amigos.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _userService.followUser(
        userId: currentUser.id,
        targetUserId: scannedId,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amigo agregado correctamente.')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo agregar: $e')),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B0A),
      appBar: AppBar(
        title: const Text('Escanear QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isProcessing) {
                return;
              }
              final barcode = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first
                  : null;
              final rawValue = barcode?.rawValue;
              if (rawValue == null || rawValue.isEmpty) {
                return;
              }
              _handleScan(rawValue);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withValues(alpha: 0.5),
              child: const Text(
                'Alinea el QR dentro del recuadro para agregar a tu amigo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
