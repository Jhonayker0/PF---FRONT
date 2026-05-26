import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/payment.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';

class ScanPaymentScreen extends StatefulWidget {
  const ScanPaymentScreen({super.key});

  @override
  State<ScanPaymentScreen> createState() => _ScanPaymentScreenState();
}

class _ScanPaymentScreenState extends State<ScanPaymentScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  ValidateQrResponse? _lastResult;
  String? _errorMessage;

  Map<String, dynamic>? _decodeQrClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleToken(String token) async {
    if (_isProcessing) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    final authToken = auth.token;
    final currentUser = auth.user;

    if (currentUser == null || authToken == null || authToken.isEmpty) {
      setState(() {
        _errorMessage = 'Debes iniciar sesión para validar el pago.';
      });
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
      return;
    }

    final claims = _decodeQrClaims(token);
    final qrUserId = claims?['user_id']?.toString();

    if (qrUserId != null && qrUserId.isNotEmpty && qrUserId != currentUser.id) {
      setState(() {
        _errorMessage = 'Este QR pertenece a otra cuenta. Inicia sesión con el usuario correcto.';
      });
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await _paymentService.validateQr(token, authToken: authToken);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastResult = result;
      });
      await _scannerController.stop();
      messenger.showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No se pudo validar el pago: $e';
      });
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
      await _scannerController.start();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final token = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (token.isEmpty) {
      return;
    }

    await _handleToken(token);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear pago'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 34),
                          const SizedBox(height: 10),
                          Text(
                            'Apunta al QR del organizador para validar el pago.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_lastResult != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6DDD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lastResult!.message,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('Evento: ${_lastResult!.eventId}'),
                    Text('Usuario: ${_lastResult!.userId}'),
                    if (_lastResult!.paymentId != null) Text('Pago: ${_lastResult!.paymentId}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String decodeQrBase64(String value) {
  final normalized = value.startsWith('data:image')
      ? value.split(',').last
      : value;
  return utf8.decode(base64Decode(normalized));
}