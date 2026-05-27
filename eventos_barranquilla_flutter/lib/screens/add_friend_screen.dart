import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  late final TextEditingController _usernameController;
  bool _isSearching = false;
  final UserService _userService = UserService();
  final RegExp _userIdPattern = RegExp(r'^[0-9a-fA-F]{24}$');
  List<User> _results = [];
  String? _errorMessage;

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

    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesion para agregar amigos.')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      if (_userIdPattern.hasMatch(username)) {
        await _userService.followUser(
          userId: currentUser.id,
          targetUserId: username,
        );
        if (!mounted) {
          return;
        }
        _usernameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amigo agregado correctamente.')),
        );
      } else {
        final results = await _userService.searchUsersByName(username);
        if (!mounted) {
          return;
        }
        setState(() {
          _results = results;
          if (results.isEmpty) {
            _errorMessage = 'No encontramos usuarios con ese nombre.';
          }
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No se pudo completar la busqueda.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _followUser(User targetUser) async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesion para agregar amigos.')),
      );
      return;
    }
    if (currentUser.id == targetUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes agregarte a ti mismo.')),
      );
      return;
    }

    try {
      await _userService.followUser(
        userId: currentUser.id,
        targetUserId: targetUser.id,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amigo agregado correctamente.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo agregar: $e')),
      );
    }
  }

  void _scanQr() {
    context.push('/add-friend/scan');
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
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFF7A6E65)),
              ),
            ],
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._results.map(
                (user) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5EFE7),
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.substring(0, 1).toUpperCase()
                            : 'U',
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: TextButton(
                      onPressed: () => _followUser(user),
                      child: const Text('Agregar'),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE8E0D7)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _scanQr,
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
