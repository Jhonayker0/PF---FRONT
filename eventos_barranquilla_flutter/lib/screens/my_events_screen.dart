import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';
import 'edit_event_screen.dart';
import 'event_detail_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final EventService _eventService = EventService();

  bool _isLoading = true;
  List<Event> _events = [];
  String? _lastUserSignature;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final signature = user == null
        ? 'guest'
        : '${user.id}|${user.role}|${user.attendedEvents.join(',')}'
          '|${user.favorites.join(',')}';

    if (_lastUserSignature != signature) {
      _lastUserSignature = signature;
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    setState(() {
      _isLoading = true;
    });

    if (user == null) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final events = user.isAdmin
          ? await _eventService.fetchEventsCreatedByOrganizer(user.id)
          : await _eventService.fetchEventsByIds(user.attendedEvents);

      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String raw) {
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final locale = Localizations.localeOf(context).toString();
      return DateFormat('EEE, d MMM · hh:mm a', locale).format(parsed);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _deleteEvent(Event event) async {
    try {
      await _eventService.deleteEvent(event.id);
      if (!mounted) return;
      await _loadEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento eliminado: ${event.title}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el evento: $e')),
      );
    }
  }

  Future<void> _showOrganizerActions(Event event) async {
    final user = context.read<AuthProvider>().user;
    if (user == null || !user.isAdmin) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1A17),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona una acción para este evento',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.58),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditEventScreen(event: event),
                            ),
                          );
                          if (mounted) {
                            await _loadEvents();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F1A17),
                          side: const BorderSide(color: Color(0xFFD9D2CA)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verificar pago aún no está conectado'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Verificar pago'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F1A17),
                          side: const BorderSide(color: Color(0xFFD9D2CA)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await _deleteEvent(event);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar evento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4111A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAdmin = user?.isAdmin ?? false;
    final title = isAdmin ? 'Mis eventos creados' : 'Mis eventos';
    final emptyMessage = user == null
        ? 'Inicia sesión para ver tus eventos'
        : isAdmin
            ? 'Aún no has creado eventos'
            : 'No tienes eventos registrados';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: _events.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 110),
                        Icon(
                          isAdmin ? Icons.event_available_outlined : Icons.event_note_outlined,
                          size: 72,
                          color: const Color(0xFFCE1126).withValues(alpha: 0.75),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            emptyMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          elevation: 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                              onTap: isAdmin
                                  ? () => _showOrganizerActions(event)
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EventDetailScreen(event: event),
                                        ),
                                      ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      height: 92,
                                      width: 92,
                                      color: const Color(0xFFF3EFE8),
                                      child: event.imageUrl.isNotEmpty
                                          ? Image.network(
                                              event.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                                            )
                                          : const Icon(Icons.event_outlined, color: Color(0xFFBFAF9F)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1F1A17),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          event.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B645C),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDate(event.date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9D8F82),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF2E8),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              isAdmin ? 'Creado por ti' : 'Asistencia confirmada',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFB65B18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}