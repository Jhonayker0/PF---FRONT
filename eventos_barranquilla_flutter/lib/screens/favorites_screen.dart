import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final EventService _eventService = EventService();
  bool _isLoading = true;
  List<Event> _events = [];
  final Set<String> _loadingFavorites = {};
  final Set<String> _loadingRegister = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final auth = context.read<AuthProvider?>();
    final user = auth?.user;
    if (user == null || user.favorites.isEmpty) {
      setState(() {
        _events = [];
        _isLoading = false;
      });
      return;
    }

    final List<Event> loaded = [];
    for (final id in user.favorites) {
      try {
        final ev = await _eventService.fetchEventById(id);
        loaded.add(ev);
      } catch (_) {
        // ignore individual fetch errors
      }
    }

    if (!mounted) return;
    setState(() {
      _events = loaded;
      _isLoading = false;
    });
  }

  String _formatDate(String raw) {
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final locale = Localizations.localeOf(context).toString();
      return DateFormat.yMMMd(locale).add_jm().format(parsed);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : auth.user == null
              ? Center(
                  child: Text('Inicia sesión para ver tus favoritos', style: Theme.of(context).textTheme.titleMedium),
                )
                  : _events.isEmpty
                  ? Center(
                      child: Text('No tienes favoritos aún', style: Theme.of(context).textTheme.titleMedium),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final ev = _events[index];
                          final isRegistered = auth.user!.attendedEvents.contains(ev.id);
                          final loadingFav = _loadingFavorites.contains(ev.id);
                          final loadingReg = _loadingRegister.contains(ev.id);

                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(event: ev))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey[100],
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: ev.imageUrl.isNotEmpty
                                            ? Image.network(ev.imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                                            : const SizedBox.shrink(),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: InkWell(
                                          onTap: loadingFav
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    _loadingFavorites.add(ev.id);
                                                  });
                                                  try {
                                                    await auth.toggleFavorite(ev.id);
                                                    await _loadFavorites();
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar favorito: $e')));
                                                  } finally {
                                                    if (mounted) {
                                                      setState(() {
                                                        _loadingFavorites.remove(ev.id);
                                                      });
                                                    }
                                                  }
                                                },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                                            child: loadingFav
                                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF28B38)))
                                                : const Icon(Icons.bookmark_remove, size: 18, color: Color(0xFFF28B38)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(ev.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(ev.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF6E6E6E), fontSize: 12)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: loadingReg
                                            ? null
                                            : () async {
                                                final user = auth.user;
                                                if (user == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión')));
                                                  return;
                                                }
                                                setState(() {
                                                  _loadingRegister.add(ev.id);
                                                });
                                                try {
                                                  if (isRegistered) {
                                                    await _eventService.leaveEvent(eventId: ev.id, userId: user.id);
                                                    user.attendedEvents.remove(ev.id);
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Has dejado de estar registrado')));
                                                  } else {
                                                    await _eventService.attendEvent(eventId: ev.id, userId: user.id);
                                                    user.attendedEvents.add(ev.id);
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Te has registrado en el evento')));
                                                  }
                                                  setState(() {});
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                                } finally {
                                                  if (mounted) {
                                                    setState(() {
                                                      _loadingRegister.remove(ev.id);
                                                    });
                                                  }
                                                }
                                              },
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6), minimumSize: const Size.fromHeight(0)),
                                        child: loadingReg
                                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                            : Text(isRegistered ? 'Anular' : 'Registrarme', style: const TextStyle(fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
