import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  String? _errorMessage;
  List<User> _connections = [];

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Inicia sesion para ver tus conexiones.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final freshUser = await _userService.fetchUser(currentUser.id);
      final followingIds = freshUser.following;
      if (followingIds.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _connections = [];
          _isLoading = false;
        });
        return;
      }

      final users = await _userService.getUsersBatch(followingIds);
      if (!mounted) {
        return;
      }
      setState(() {
        _connections = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No se pudieron cargar las conexiones.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        title: const Text('Conexiones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF7A6E65)),
                    ),
                  )
                : _connections.isEmpty
                    ? const Center(
                        child: Text(
                          'Aun no tienes conexiones agregadas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF7A6E65)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _connections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = _connections[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFF5EFE7),
                                backgroundImage: user.profilePicture != null &&
                                        user.profilePicture!.isNotEmpty
                                    ? NetworkImage(user.profilePicture!)
                                    : null,
                                child: user.profilePicture == null ||
                                        user.profilePicture!.isEmpty
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'U',
                                      )
                                    : null,
                              ),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
