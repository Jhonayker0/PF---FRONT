import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';

/// Componente Discover: Carousel horizontal de eventos destacados
class DiscoverEvents extends StatefulWidget {
  final List<Event> events;
  final ThemeData themeData;

  const DiscoverEvents({
    required this.events,
    required this.themeData,
    Key? key,
  }) : super(key: key);

  @override
  _DiscoverEventsState createState() => _DiscoverEventsState();
}

class _DiscoverEventsState extends State<DiscoverEvents> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Descubre',
            style: widget.themeData.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.events.length,
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return _DiscoverCard(
                event: event,
                themeData: widget.themeData,
                onTap: () => context.push('/event-detail', extra: {'event': event, 'heroTag': 'event_discover_${event.id}'}),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Card individual para Discover
class _DiscoverCard extends StatelessWidget {
  final Event event;
  final ThemeData themeData;
  final VoidCallback onTap;

  const _DiscoverCard({
    required this.event,
    required this.themeData,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Hero(
          tag: 'event_discover_${event.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                    const Color(0xFFFCD116).withValues(alpha: 0.88),
                    const Color(0xFF078930).withValues(alpha: 1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Fondo con imagen
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                // Overlay oscuro
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Categoría badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          event.categoryLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                      // Título
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Fecha y ubicación
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                event.date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }
}

/// Componente Scrolling: Lista horizontal de eventos
class ScrollingEvents extends StatefulWidget {
  final String title;
  final List<Event> events;
  final ThemeData themeData;

  const ScrollingEvents({
    required this.title,
    required this.events,
    required this.themeData,
    Key? key,
  }) : super(key: key);

  @override
  State<ScrollingEvents> createState() => _ScrollingEventsState();
}

class _ScrollingEventsState extends State<ScrollingEvents> {
  late ScrollController _controller;
  int _displayCount = 0;
  static const int _pageSize = 6;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _displayCount = widget.events.length < _pageSize ? widget.events.length : _pageSize;
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ScrollingEvents oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      final nextCount = widget.events.length < _pageSize ? widget.events.length : _pageSize;
      setState(() {
        _displayCount = nextCount;
      });
      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
    }
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final pos = _controller.position.pixels;
    if (max - pos < 200 && _displayCount < widget.events.length) {
      setState(() {
        _displayCount = (_displayCount + _pageSize).clamp(0, widget.events.length);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            widget.title,
            style: widget.themeData.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _displayCount > widget.events.length ? widget.events.length : _displayCount,
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return _ScrollingEventCard(
                event: event,
                themeData: widget.themeData,
                onTap: () => context.push('/event-detail', extra: {'event': event, 'heroTag': 'event_scroll_${event.id}'}),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Card individual para ScrollingEvents
class _ScrollingEventCard extends StatelessWidget {
  final Event event;
  final ThemeData themeData;
  final VoidCallback onTap;

  const _ScrollingEventCard({
    required this.event,
    required this.themeData,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Hero(
          tag: 'event_scroll_${event.id}',
          child: SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen container
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Título
                Text(
                  event.title,
                  style: themeData.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Componente ParticularCategory: Lista vertical detallada por categoría
class ParticularCategoryEvents extends StatelessWidget {
  final String categoryName;
  final List<Event> events;
  final ThemeData themeData;

  const ParticularCategoryEvents({
    required this.categoryName,
    required this.events,
    required this.themeData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: themeData.primaryColor,
          child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _CategoryEventCard(
            event: event,
            themeData: themeData,
            onTap: () => context.push('/event-detail', extra: {'event': event, 'heroTag': 'event_category_${event.id}'}),
          );
        },
      ),
    );
  }
}

/// Card individual para ParticularCategoryEvents
class _CategoryEventCard extends StatelessWidget {
  final Event event;
  final ThemeData themeData;
  final VoidCallback onTap;

  const _CategoryEventCard({
    required this.event,
    required this.themeData,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF078930).withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Imagen container
              Hero(
                tag: 'event_category_${event.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.all(12),
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              // Información
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: themeData.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.categoryLabel,
                            style: TextStyle(
                              color: const Color(0xFF078930),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: const Color(0xFF078930),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.date,
                              style: themeData.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF078930),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location,
                              style: themeData.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
