import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({required this.event, this.heroTag, super.key});

  final Event event;
  final String? heroTag;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final PageController _imageController;
  int _currentImageIndex = 0;
  final Map<int, double> _imageHeights = {};
  static const double _fallbackImageHeight = 240;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _measureImageHeights();
      }
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<String> get _images {
    return widget.event.pictureUrls.isNotEmpty
        ? widget.event.pictureUrls
        : [widget.event.imageUrl];
  }

  double get _currentImageHeight {
    return _imageHeights[_currentImageIndex] ?? _fallbackImageHeight;
  }

  double _imageHeightFor(int index) {
    return _imageHeights[index] ?? _fallbackImageHeight;
  }

  Future<void> _measureImageHeights() async {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final heights = <int, double>{};

    for (var index = 0; index < _images.length; index++) {
      final imageUrl = _images[index];
      final completer = Completer<Size>();
      final imageProvider = NetworkImage(imageUrl);
      final stream = imageProvider.resolve(const ImageConfiguration());

      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (imageInfo, synchronousCall) {
          completer.complete(
            Size(
              imageInfo.image.width.toDouble(),
              imageInfo.image.height.toDouble(),
            ),
          );
          stream.removeListener(listener);
        },
        onError: (error, stackTrace) {
          if (!completer.isCompleted) {
            completer.complete(const Size(1, _fallbackImageHeight));
          }
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);

      try {
        final size = await completer.future;
        final ratio = size.height / size.width;
        heights[index] = screenWidth * ratio;
      } catch (_) {
        heights[index] = _fallbackImageHeight;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _imageHeights
        ..clear()
        ..addAll(heights);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              height: _currentImageHeight,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _imageController,
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = _images[index];
                      final image = ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: _imageHeightFor(index),
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 80),
                          ),
                        ),
                      );

                      if (index == 0) {
                        return Hero(
                          tag: widget.heroTag ?? 'event_${widget.event.id}',
                          child: SizedBox(
                            width: double.infinity,
                            height: _imageHeightFor(0),
                            child: image,
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: _imageHeightFor(index),
                        child: image,
                      );
                    },
                  ),
                  if (_images.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (index) {
                          final isActive = index == _currentImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 22 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            // Event details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.event.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 18,
                        color: Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.event.price == 0.0
                            ? 'Gratis'
                            : '\$${widget.event.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.event.date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final user = context.read<AuthProvider>().user;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesion para registrarte'),
                            ),
                          );
                          return;
                        }

                        try {
                          await eventService.attendEvent(
                            eventId: widget.event.id,
                            userId: user.id,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Te has registrado en el evento!'),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No se pudo registrar: $e'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Registrarse al Evento'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Evento guardado!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_outline),
                      label: const Text('Guardar Evento'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
