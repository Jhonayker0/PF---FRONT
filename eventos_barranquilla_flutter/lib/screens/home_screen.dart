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
  late TextEditingController _searchController;
  String _searchQuery = '';

  

  late Map<String, List<Event>> _eventsByCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _eventsByCategory = _groupEventsByCategory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Event> _filterEvents(List<Event> events) {
    if (_searchQuery.isEmpty) {
      return events;
    }
    final query = _searchQuery.toLowerCase();
    return events
        .where((event) =>
            event.title.toLowerCase().contains(query) ||
            event.category.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query))
        .toList();
  }

  Map<String, List<Event>> _getFilteredEventsByCategory() {
    if (_searchQuery.isEmpty) {
      return _eventsByCategory;
    }
    final filtered = <String, List<Event>>{};
    for (final entry in _eventsByCategory.entries) {
      final categoryEvents = _filterEvents(entry.value);
      if (categoryEvents.isNotEmpty) {
        filtered[entry.key] = categoryEvents;
      }
    }
    return filtered;
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
                              ],
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
                                  backgroundColor: const Color(0xFFCE1126),
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
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Buscar eventos...',
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFF8A7F73)),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Color(0xFF8A7F73)),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
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
                                    color: Color(0xFFCE1126),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    // Display search results or all events
                    if (_searchQuery.isEmpty)
                      Column(
                        children: [
                          // Discover carousel
                          DiscoverEvents(
                            events: _events.take(5).toList(),
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
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Resultados de búsqueda',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._getFilteredEventsByCategory()
                              .entries
                              .map((entry) {
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
                          if (_getFilteredEventsByCategory().isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    const Icon(
                                      Icons.search_off,
                                      size: 56,
                                      color: Color(0xFFC4B5A0),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No se encontraron eventos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8A7F73),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Intenta con otra búsqueda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFC4B5A0),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
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
