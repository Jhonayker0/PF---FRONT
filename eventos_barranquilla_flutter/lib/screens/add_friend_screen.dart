import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  late final TextEditingController _usernameController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _searchByUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre de usuario.')),
      );
      return;
    }

    setState(() => _isSearching = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() => _isSearching = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Busqueda enviada.')),
    );
  }

  void _scanQrPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escaneo QR pendiente de integrar.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        title: const Text('Anadir amigo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elige como agregar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1A17),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Busca por usuario o escanea el QR de la Smart ID.',
              style: TextStyle(color: Color(0xFF7A6E65)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Nombre de usuario',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _searchByUsername(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchByUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4111A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.search),
                label: Text(_isSearching ? 'Buscando...' : 'Buscar'),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE8E0D7)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _scanQrPlaceholder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1F1A17),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE8E0D7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
