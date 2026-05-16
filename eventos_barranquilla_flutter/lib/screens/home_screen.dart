import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/events_mock.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../widgets/event_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Event> _events = mockEvents;

  late Map<String, List<Event>> _eventsByCategory;

  @override
  void initState() {
    super.initState();
    _eventsByCategory = _groupEventsByCategory();
  }

  Map<String, List<Event>> _groupEventsByCategory() {
    final Map<String, List<Event>> grouped = {};
    for (final event in _events) {
      if (!grouped.containsKey(event.category)) {
        grouped[event.category] = [];
      }
      grouped[event.category]!.add(event);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isAdmin = user?.role == 'admin';
        final theme = Theme.of(context);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF9F4EB), Color(0xFFF3EFE8)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bienvenido,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8A7F73),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.name ?? 'Usuario',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF181818),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _RolePill(
                                      label: isAdmin
                                          ? '👨‍💼 Organizador'
                                          : '👤 Cliente',
                                      color: isAdmin
                                          ? const Color(0xFFFFEEE6)
                                          : const Color(0xFFE8F0FF),
                                      textColor: const Color(0xFF181818),
                                    ),
                                    _RolePill(
                                      label: '${_events.length} eventos',
                                      color: Colors.white,
                                      textColor: const Color(0xFF6C63FF),
                                      borderColor: const Color(0xFFE7DFD4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Cerrar sesión'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas cerrar sesión?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        authProvider.signOut();
                                        Navigator.pop(dialogContext);
                                        context.go('/login');
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Cerrar sesión'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'Salir',
                              style: TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        isAdmin
                            ? 'Administra y crea experiencias culturales.'
                            : 'Descubre los próximos eventos culturales de la ciudad.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF6B645C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Action button or search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isAdmin
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => context.go('/create-event'),
                                icon: const Icon(Icons.add),
                                label: const Text('Crear Nuevo Evento'),
                              ),
                            )
                          : TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar eventos...',
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFF8A7F73)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE7DFD4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6C63FF),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    // Discover carousel
                    DiscoverEvents(
                      events:
                          _events.take(5).toList(), // Primeros 5 eventos
                      themeData: theme,
                    ),
                    const SizedBox(height: 28),
                    // Scrolling events by category
                    ..._eventsByCategory.entries.map((entry) {
                      final category = entry.key;
                      final categoryEvents = entry.value;
                      return Column(
                        children: [
                          ScrollingEvents(
                            title: category,
                            events: categoryEvents,
                            themeData: theme,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.color,
    required this.textColor,
    this.borderColor,
  });

  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
