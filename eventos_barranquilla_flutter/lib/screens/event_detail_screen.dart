import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';
import '../services/user_service.dart';

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
  bool _isSavingFavorite = false;
  bool _isRegistered = false;
  bool _isTogglingRegister = false;
  final UserService _userService = UserService();
  User? _organizerUser;
  bool _isLoadingOrganizer = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _measureImageHeights();
        // Initialize registration state from AuthProvider if available
        final auth = context.read<AuthProvider?>();
        if (auth != null && auth.user != null) {
          _isRegistered = auth.user!.attendedEvents.contains(widget.event.id);
        }
      }
    });
    _loadOrganizer();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<String> get _images {
    if (widget.event.pictureUrls.isNotEmpty) return widget.event.pictureUrls;
    if (widget.event.imageUrl.isNotEmpty) return [widget.event.imageUrl];
    return <String>[];
  }

  double get _currentImageHeight {
    return _imageHeights[_currentImageIndex] ?? _fallbackImageHeight;
  }

  double _imageHeightFor(int index) {
    return _imageHeights[index] ?? _fallbackImageHeight;
  }
  String get _organizerLookupId {
    if (widget.event.organizerId.isNotEmpty) {
      return widget.event.organizerId;
    }
    final fallback = widget.event.organizerName.trim();
    final objectIdPattern = RegExp(r'^[a-fA-F0-9]{24}$');
    if (objectIdPattern.hasMatch(fallback)) {
      return fallback;
    }
    return '';
  }

  Future<void> _loadOrganizer() async {
    final organizerId = _organizerLookupId;
    if (organizerId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingOrganizer = true;
    });

    try {
      final organizer = await _userService.fetchUser(organizerId);
      if (!mounted) return;
      setState(() {
        _organizerUser = organizer;
      });
    } catch (_) {
      // keep fallback values
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrganizer = false;
        });
      }
    }
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

    if (!mounted) return;

    setState(() {
      _imageHeights
        ..clear()
        ..addAll(heights);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isFavorite = authProvider.isFavorite(widget.event.id);
    final isOrganizer = authProvider.user?.isAdmin ?? false;
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
            if (_images.isEmpty)
              Container(
                height: 480,
                width: double.infinity,
                color: Colors.black,
              )
            else
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
                        bottom: 40,
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
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.event.categoryLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDD6B20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B1B1B),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFF28B38), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: const TextStyle(
                            color: Color(0xFF5B5B5B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule, color: Color(0xFFF28B38), size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatEventDate(widget.event.date, context),
                          style: const TextStyle(
                            color: Color(0xFF5B5B5B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6E6E6E),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Organizador',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFFFE5CF),
                          backgroundImage: _organizerUser?.profilePicture != null &&
                                  _organizerUser!.profilePicture!.isNotEmpty
                              ? NetworkImage(_organizerUser!.profilePicture!)
                              : null,
                          child: _organizerUser?.profilePicture == null ||
                                  _organizerUser!.profilePicture!.isEmpty
                              ? const Icon(Icons.person, color: Color(0xFFF28B38))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _organizerUser?.name.isNotEmpty == true
                                    ? _organizerUser!.name
                                    : widget.event.organizerName.isNotEmpty &&
                                            !_organizerLookupId.contains(widget.event.organizerName)
                                        ? widget.event.organizerName
                                    : 'Organizador no disponible',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF242424),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.sell_outlined,
                        label: widget.event.price == 0.0
                            ? 'Gratis'
                            : '\$${widget.event.price.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 10),
                      _InfoPill(
                        icon: Icons.photo_library_outlined,
                        label: '${_images.length} imágenes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOrganizer ? const Color(0xFFD9D2CA) : const Color(0xFFF28B38),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: isOrganizer
                          ? null
                          : () async {
                        final user = authProvider.user;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesión para registrarte'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isTogglingRegister = true;
                        });

                        try {
                          if (_isRegistered) {
                            await eventService.leaveEvent(
                              eventId: widget.event.id,
                              userId: user.id,
                            );
                            if (!context.mounted) return;
                            setState(() {
                              _isRegistered = false;
                            });
                            try {
                              final currentUser = authProvider.user;
                              currentUser?.attendedEvents.remove(widget.event.id);
                            } catch (_) {}
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Has dejado de estar registrado en el evento'),
                              ),
                            );
                          } else {
                            await eventService.attendEvent(
                              eventId: widget.event.id,
                              userId: user.id,
                            );
                            if (!context.mounted) return;
                            setState(() {
                              _isRegistered = true;
                            });
                            try {
                              final currentUser = authProvider.user;
                              if (currentUser != null && !currentUser.attendedEvents.contains(widget.event.id)) {
                                currentUser.attendedEvents.add(widget.event.id);
                              }
                            } catch (_) {}
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Te has registrado en el evento!'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No se pudo cambiar el estado de registro: $e'),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isTogglingRegister = false;
                            });
                          }
                        }
                      },
                      icon: isOrganizer
                          ? const Icon(Icons.block_outlined)
                          : _isTogglingRegister
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(_isRegistered ? Icons.check_circle : Icons.check_circle_outline),
                      label: isOrganizer
                          ? const Text('Solo favoritos para organizadores')
                          : _isTogglingRegister
                              ? const Text('Procesando...')
                              : Text(_isRegistered ? 'Registrado' : 'Registrarme'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF28B38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFF28B38), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _isSavingFavorite
                          ? null
                          : () async {
                              if (!authProvider.isAuthenticated) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Inicia sesión para guardar eventos'),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isSavingFavorite = true;
                              });

                              try {
                                final nowFavorite = await authProvider.toggleFavorite(widget.event.id);
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      nowFavorite
                                          ? 'Evento guardado en favoritos'
                                          : 'Evento eliminado de favoritos',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No se pudo actualizar favorito: $e'),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSavingFavorite = false;
                                  });
                                }
                              }
                            },
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                      ),
                      label: Text(
                        _isSavingFavorite
                            ? 'Guardando...'
                            : isFavorite
                                ? 'Quitar de guardados'
                                : 'Guardar evento',
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatEventDate(String raw, BuildContext context) {
  if (raw.trim().isEmpty) return '';
  try {
    final parsed = DateTime.parse(raw).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(parsed.year, parsed.month, parsed.day);
    final diffDays = eventDay.difference(today).inDays;
    final locale = Localizations.localeOf(context).toString();
    final timeFmt = DateFormat.jm(locale);

    if (diffDays == 0) {
      return 'Hoy · ${timeFmt.format(parsed)}';
    }
    if (diffDays == 1) {
      return 'Mañana · ${timeFmt.format(parsed)}';
    }
    if (diffDays > 1 && diffDays < 7) {
      final weekday = DateFormat.EEEE(locale).format(parsed);
      return '$weekday · ${timeFmt.format(parsed)}';
    }

    final datePart = DateFormat('EEE, d MMM', locale).format(parsed);
    return '$datePart · ${timeFmt.format(parsed)}';
  } catch (e) {
    return raw;
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFF28B38)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB65B18),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
