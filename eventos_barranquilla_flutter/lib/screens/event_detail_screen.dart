import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/event_review.dart';
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
  final EventService _eventService = EventService();
  bool _isSavingFavorite = false;
  bool _isRegistered = false;
  bool _isTogglingRegister = false;
  final UserService _userService = UserService();
  User? _organizerUser;
  bool _isLoadingReviews = false;
  String? _reviewsError;
  List<EventReview> _reviews = [];

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
    _loadReviews();
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

  DateTime? get _eventDate {
    try {
      return DateTime.parse(widget.event.date).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool get _eventHasPassed {
    final eventDate = _eventDate;
    if (eventDate == null) return false;
    return DateTime.now().isAfter(eventDate);
  }

  EventReview? _currentUserReview(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    for (final review in _reviews) {
      if (review.userId == userId) {
        return review;
      }
    }
    return null;
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final reviews = await _eventService.fetchEventReviews(widget.event.id);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reviewsError = 'No pudimos cargar las reseñas: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  void _openAllReviews() {
    context.push('/event-reviews', extra: widget.event).then((_) {
      if (mounted) {
        _loadReviews();
      }
    });
  }

  Widget _buildReviewsPreviewSection({
    required bool canReview,
    required EventReview? currentUserReview,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DED2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.reviews_outlined, color: Color(0xFF078930), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Reseñas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              TextButton(
                onPressed: _openAllReviews,
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFCD116)),
              const SizedBox(width: 4),
              Text(
                _reviews.isEmpty ? 'Sin calificaciones aún' : (_reviews.fold<int>(0, (sum, review) => sum + review.star) / _reviews.length).toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              Text(
                '${_reviews.length} reseñas',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingReviews)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_reviewsError != null)
            _ReviewEmptyState(
              icon: Icons.error_outline_rounded,
              message: _reviewsError!,
              actionLabel: 'Reintentar',
              onAction: _loadReviews,
            )
          else if (_reviews.isEmpty)
            _ReviewEmptyState(
              icon: Icons.reviews_outlined,
              message: canReview
                  ? currentUserReview == null
                      ? 'Sé la primera persona en compartir tu experiencia.'
                      : 'Ya tienes una reseña publicada. Puedes editarla.'
                  : 'Cuando haya opiniones aparecerán aquí.',
              actionLabel: canReview
                  ? (currentUserReview == null ? 'Añadir reseña' : 'Editar mi reseña')
                  : null,
              onAction: canReview
                  ? () {
                      context.push('/event-reviews', extra: widget.event).then((_) {
                        if (mounted) {
                          _loadReviews();
                        }
                      });
                    }
                  : null,
            )
          else
            Column(
              children: [
                for (final review in _reviews.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CompactReviewCard(review: review),
                  ),
                if (_reviews.length > 2)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _openAllReviews,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Ver todas las reseñas'),
                    ),
                  ),
              ],
            ),
          if (canReview) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF078930),
                  side: const BorderSide(color: Color(0xFF078930)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => context.push('/event-reviews', extra: widget.event).then((_) {
                  if (mounted) {
                    _loadReviews();
                  }
                }),
                icon: Icon(currentUserReview == null ? Icons.rate_review_outlined : Icons.edit_outlined),
                label: Text(currentUserReview == null ? 'Añadir reseña' : 'Editar mi reseña'),
              ),
            ),
          ],
        ],
      ),
    );
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

    try {
      final organizer = await _userService.fetchUser(organizerId);
      if (!mounted) return;
      setState(() {
        _organizerUser = organizer;
      });
    } catch (_) {
      // keep fallback values
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

  Future<bool> _confirmRegistration() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar inscripción'),
          content: Text('¿Deseas inscribirte a "${widget.event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF078930),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    return accepted ?? false;
  }

  Future<void> _showRegistrationSuccessAnimation() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RegistrationSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isFavorite = authProvider.isFavorite(widget.event.id);
    final isOrganizer = authProvider.user?.isAdmin ?? false;
    final currentUser = authProvider.user;
    final currentUserReview = _currentUserReview(currentUser?.id);
    final attended = currentUser != null && currentUser.attendedEvents.contains(widget.event.id);
    final canReview = attended && _eventHasPassed;

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
                                  ? const Color(0xFF078930)
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
                      color: const Color(0xFFEAF6EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.event.categoryLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF078930),
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
                      const Icon(Icons.location_on, color: Color(0xFF078930), size: 18),
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
                      const Icon(Icons.schedule, color: Color(0xFF078930), size: 18),
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
                          backgroundColor: const Color(0xFFEAF6EC),
                          backgroundImage: _organizerUser?.profilePicture != null &&
                                  _organizerUser!.profilePicture!.isNotEmpty
                              ? NetworkImage(_organizerUser!.profilePicture!)
                              : null,
                          child: _organizerUser?.profilePicture == null ||
                                  _organizerUser!.profilePicture!.isEmpty
                              ? const Icon(Icons.person, color: Color(0xFF078930))
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
                  const SizedBox(height: 18),
                  _buildReviewsPreviewSection(
                    canReview: canReview,
                    currentUserReview: currentUserReview,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOrganizer ? const Color(0xFFD9D2CA) : const Color(0xFF078930),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: isOrganizer
                          ? null
                          : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final user = authProvider.user;
                        if (user == null) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesión para registrarte'),
                            ),
                          );
                          return;
                        }

                        if (!_isRegistered) {
                          final accepted = await _confirmRegistration();
                          if (!accepted || !mounted) {
                            return;
                          }
                        }

                        setState(() {
                          _isTogglingRegister = true;
                        });

                        try {
                          if (_isRegistered) {
                            await _eventService.leaveEvent(
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
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Has dejado de estar registrado en el evento'),
                              ),
                            );
                          } else {
                            await _eventService.attendEvent(
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
                            await _showRegistrationSuccessAnimation();
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('¡Te has registrado en el evento!'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          messenger.showSnackBar(
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
                        foregroundColor: const Color(0xFF078930),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF078930), width: 1.2),
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

class _CompactReviewCard extends StatelessWidget {
  const _CompactReviewCard({required this.review});

  final EventReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DED2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEAF6EC),
                backgroundImage: review.profilePictureUrl.isNotEmpty ? NetworkImage(review.profilePictureUrl) : null,
                child: review.profilePictureUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF078930), size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Usuario anónimo',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B1B1B)),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(5, (index) {
                        final active = index < review.star;
                        return Icon(
                          active ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16,
                          color: const Color(0xFFFCD116),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.reviewText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.45, color: Color(0xFF5F5F5F)),
          ),
        ],
      ),
    );
  }
}

class _ReviewEmptyState extends StatelessWidget {
  const _ReviewEmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DED2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF078930)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
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
        color: const Color(0xFFEAF6EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF078930)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF078930),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationSuccessDialog extends StatefulWidget {
  const _RegistrationSuccessDialog();

  @override
  State<_RegistrationSuccessDialog> createState() => _RegistrationSuccessDialogState();
}

class _RegistrationSuccessDialogState extends State<_RegistrationSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _controller.forward().whenComplete(() async {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final checkOpacity = ((progress - 0.62) / 0.38).clamp(0.0, 1.0);
            final checkScale = 0.7 + (0.3 * checkOpacity);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        value: progress,
                        color: const Color(0xFF078930),
                        backgroundColor: const Color(0xFFEAF6EC),
                      ),
                    ),
                    Opacity(
                      opacity: checkOpacity,
                      child: Transform.scale(
                        scale: checkScale,
                        child: const Icon(
                          Icons.check_circle,
                          size: 58,
                          color: Color(0xFF078930),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Inscripción confirmada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu cupo quedó guardado correctamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
