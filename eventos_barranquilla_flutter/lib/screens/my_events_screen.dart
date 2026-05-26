import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/event_attendee.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../models/payment.dart';
import '../services/event_service.dart';
import '../services/payment_service.dart';
import 'confirmed_event_ticket_screen.dart';
import 'edit_event_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final EventService _eventService = EventService();
  final PaymentService _paymentService = PaymentService();

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
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _eventService.deleteEvent(event.id);
      if (!mounted) return;
      await _loadEvents();
      messenger.showSnackBar(SnackBar(content: Text('Evento eliminado: ${event.title}')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('No se pudo eliminar el evento: $e')));
    }
  }

  Uint8List _decodeQrImage(String value) {
    final normalized = value.startsWith('data:image') ? value.split(',').last : value;
    return base64Decode(normalized);
  }

  Future<void> _showPaymentQrDialog(
    Event event,
    EventAttendee attendee,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final organizerToken = context.read<AuthProvider>().token;

    try {
      final payment = await _paymentService.initiatePayment(
        userId: attendee.id,
        eventId: event.id,
        token: organizerToken,
      );

      if (!mounted) {
        return;
      }

      String currentStatus = payment.status;
      Timer? poller;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setStateDialog) {
              // start polling once dialog is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                poller ??= Timer.periodic(const Duration(seconds: 3), (t) async {
                  try {
                    final updated = await _paymentService.getPayment(payment.paymentId, token: organizerToken);
                    if (updated.status != currentStatus) {
                      currentStatus = updated.status;
                      setStateDialog(() {});
                      if (updated.status.toLowerCase() == 'confirmed' || updated.status.toLowerCase() == 'paid') {
                        t.cancel();
                      }
                    }
                  } catch (_) {
                    // ignore polling errors
                  }
                });
              });

              return AlertDialog(
                title: const Text('QR de pago generado'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Asistente: ${attendee.displayName}'),
                      const SizedBox(height: 14),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            _decodeQrImage(payment.qrCodeBase64),
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Estado: $currentStatus'),
                      const SizedBox(height: 4),
                      SelectableText(payment.qrToken),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      poller?.cancel();
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      final errorText = e.toString();

      if (e is ApiException) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Error generando QR de pago'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Código: ${e.statusCode}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Respuesta del backend:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(e.message),
                    const SizedBox(height: 12),
                    const Text(
                      'Request:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    SelectableText('user_id=${attendee.id}\nevent_id=${event.id}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo generar el QR de pago: $errorText')),
      );
    }
  }

  Future<void> _showPaymentVerification(Event event) async {
    final messenger = ScaffoldMessenger.of(context);
    final user = context.read<AuthProvider>().user;
    final organizerToken = context.read<AuthProvider>().token;
    if (user == null || !user.isAdmin) {
      return;
    }

    try {
      final attendees = await _eventService.fetchAttendees(event.id);
      // Fetch payments for this event and map by user_id for quick lookup
      final eventPayments = await _paymentService.getEventPayments(event.id, token: organizerToken);
      final Map<String, PaymentResponse> paymentsByUser = {
        for (final p in eventPayments) p.userId: p
      };
      if (!mounted) {
        return;
      }

      if (attendees.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Todavía no hay asistentes para este evento')),
        );
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
                        'Selecciona un asistente',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF1F1A17),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.58),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(sheetContext).size.height * 0.65,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: attendees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final attendee = attendees[index];
                            final payment = paymentsByUser[attendee.id];
                            return Material(
                              color: const Color(0xFFF8F3EA),
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () async {
                                  Navigator.pop(sheetContext);
                                  // If already paid, show details instead of generating new QR
                                  if (payment != null &&
                                      (payment.status.toLowerCase() == 'confirmed' || payment.status.toLowerCase() == 'paid')) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Pago ya validado: ${payment.id}')),
                                    );
                                    return;
                                  }

                                  await _showPaymentQrDialog(event, attendee);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(0xFFEAF6EC),
                                        backgroundImage: attendee.profilePicture != null && attendee.profilePicture!.isNotEmpty
                                            ? NetworkImage(attendee.profilePicture!)
                                            : null,
                                        child: attendee.profilePicture == null || attendee.profilePicture!.isEmpty
                                            ? Text(
                                                attendee.displayName.isNotEmpty ? attendee.displayName.substring(0, 1).toUpperCase() : 'A',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF078930),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              attendee.displayName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1F1A17),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              attendee.email.isNotEmpty ? attendee.email : attendee.id,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B645C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Color(0xFF8A847D)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
    } catch (e) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los asistentes: $e')),
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
                          _showPaymentVerification(event);
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
                          color: const Color(0xFF078930).withValues(alpha: 0.75),
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
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: isAdmin
                                ? () => _showOrganizerActions(event)
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ConfirmedEventTicketScreen(event: event),
                                      ),
                                    ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
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
                                        const SizedBox.shrink(),
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