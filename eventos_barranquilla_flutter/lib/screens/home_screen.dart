import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/user_mock.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';
import '../widgets/event_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  static const List<String> _defaultCategories = [
    'Festival',
    'Música',
    'Arte',
    'Cultura',
    'Deporte',
    'Gastronomía',
  ];

  List<Event> _featuredEvents = [];
  Map<String, List<Event>> _eventsByCategory = {};
  bool _isLoading = true;
  String? _errorMessage;
  late TextEditingController _searchController;
  String _searchQuery = '';
  late Map<String, List<Event>> _eventsByCategory;
  bool _loginPromptShown = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated && !_loginPromptShown) {
        _loginPromptShown = true;
        _showLoginPrompt();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final popularEvents = await _eventService.fetchPopularEvents();
      final categories = await Future.wait(
        _defaultCategories.map((category) async {
          final events = await _eventService.fetchEventsByCategory(category);
          return MapEntry(category, events);
        }),
      );

      final Map<String, List<Event>> groupedByCategory = {};
      final Map<String, Event> deduplicatedEvents = {};

      for (final event in popularEvents) {
        deduplicatedEvents[event.id] = event;
      }

      for (final entry in categories) {
        final categoryEvents = entry.value;
        if (categoryEvents.isNotEmpty) {
          groupedByCategory[entry.key] = categoryEvents;
        }
        for (final event in categoryEvents) {
          deduplicatedEvents[event.id] = event;
        }
      }

      setState(() {
        _featuredEvents = popularEvents.isNotEmpty
            ? popularEvents.take(5).toList()
            : deduplicatedEvents.values.take(5).toList();
        final allEvents = deduplicatedEvents.values.toList();
        _eventsByCategory = groupedByCategory.isNotEmpty
            ? groupedByCategory
          : _groupEventsByCategory(allEvents);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No pudimos cargar los eventos. Intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  Map<String, List<Event>> _groupEventsByCategory(List<Event> events) {
    final Map<String, List<Event>> grouped = {};
    for (final event in events) {
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

  Future<void> _showLoginPrompt() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.48,
          minChildSize: 0.35,
          maxChildSize: 0.78,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 30,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1F1A17), Color(0xFF3A2F28)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 42,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Inicia sesión para una experiencia completa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sin sesión puedes explorar, pero al entrar podrás ver tu perfil, favoritos y contenido personalizado.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PromptFeatureRow(
                                icon: Icons.verified_user_outlined,
                                title: 'Perfil y estadísticas',
                                subtitle: 'Verás tu información y progreso dentro de la app.',
                              ),
                              const SizedBox(height: 14),
                              _PromptFeatureRow(
                                icon: Icons.favorite_border,
                                title: 'Favoritos y guardados',
                                subtitle: 'Accede a tus eventos preferidos desde cualquier pantalla.',
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: const Color(0xFFCE1126),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    context.go('/login');
                                  },
                                  child: const Text('Ir al login'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  child: const Text('Ahora no'),
                                ),
                              ),
                            ],
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
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isAuthenticated;
        final user = isLoggedIn ? mockUser : null;
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
                                Text(
                                  isLoggedIn ? 'Bienvenido,' : 'Explora eventos',
                                  style: const TextStyle(
                                Text(
                                  isLoggedIn ? 'Bienvenido,' : 'Explora eventos',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8A7F73),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isLoggedIn ? user!.name : 'Agenda cultural de Barranquilla',
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
                        !isLoggedIn
                            ? 'Revisa eventos, descubre categorías y entra al login cuando quieras guardar tu experiencia.'
                            : isAdmin
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
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF6B645C),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadEvents,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCE1126),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    // Display search results or all events
                    else if (_searchQuery.isEmpty)
                      Column(
                        children: [
                          // Discover carousel
                          DiscoverEvents(
                            events: _featuredEvents,
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

class _PromptFeatureRow extends StatelessWidget {
  const _PromptFeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFE7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFCE1126)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF181818),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF6B645C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
