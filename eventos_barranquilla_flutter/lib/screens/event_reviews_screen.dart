import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/event_review.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';

class EventReviewsScreen extends StatefulWidget {
  const EventReviewsScreen({required this.event, super.key});

  final Event event;

  @override
  State<EventReviewsScreen> createState() => _EventReviewsScreenState();
}

class _EventReviewsScreenState extends State<EventReviewsScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _selectedStar = 5;
  List<EventReview> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  DateTime? get _eventDate {
    try {
      return DateTime.parse(widget.event.date).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool get _hasEventPassed {
    final eventDate = _eventDate;
    if (eventDate == null) return false;
    return DateTime.now().isAfter(eventDate);
  }

  EventReview? _currentUserReview(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return null;
    for (final review in _reviews) {
      if (review.userId == currentUserId) {
        return review;
      }
    }
    return null;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(0, (sum, review) => sum + review.star);
    return total / _reviews.length;
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        _errorMessage = 'No se pudieron cargar las reseñas: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openReviewForm({EventReview? existingReview}) async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.user;
    if (currentUser == null) return;

    _reviewController.text = existingReview?.reviewText ?? '';
    _selectedStar = existingReview?.star ?? 5;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6DDD2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          existingReview == null ? 'Escribe tu reseña' : 'Editar reseña',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tu opinión ayuda a otros asistentes a decidirse.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Calificación',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF242424)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            final active = star <= _selectedStar;
                            return IconButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      setSheetState(() {
                                        _selectedStar = star;
                                      });
                                    },
                              icon: Icon(
                                active ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: const Color(0xFFFCD116),
                                size: 30,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reviewController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Cuéntanos qué te pareció el evento...',
                            filled: true,
                            fillColor: const Color(0xFFF8F5F1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF078930),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    final navigator = Navigator.of(sheetContext);
                                    final messenger = ScaffoldMessenger.of(context);
                                    final authProvider = context.read<AuthProvider>();
                                    final currentUserId = currentUser.id;
                                    final authToken = auth.token;

                                    final reviewText = _reviewController.text.trim();
                                    if (reviewText.isEmpty) {
                                      messenger.showSnackBar(
                                        const SnackBar(content: Text('Escribe tu reseña')),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _isSubmitting = true;
                                    });

                                    try {
                                      if (existingReview == null) {
                                        await _eventService.addEventReview(
                                          eventId: widget.event.id,
                                          userId: currentUserId,
                                          reviewText: reviewText,
                                          star: _selectedStar,
                                          token: authToken,
                                        );
                                      } else {
                                        await _eventService.updateEventReview(
                                          eventId: widget.event.id,
                                          userId: currentUserId,
                                          reviewText: reviewText,
                                          star: _selectedStar,
                                          token: authToken,
                                        );
                                      }
                                      if (!mounted) return;
                                      await authProvider.refreshProfileStats();
                                      navigator.pop(true);
                                    } catch (e) {
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(content: Text('No se pudo guardar la reseña: $e')),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isSubmitting = false;
                                        });
                                      }
                                    }
                                  },
                            child: Text(_isSubmitting ? 'Guardando...' : 'Guardar reseña'),
                          ),
                        ),
                        if (existingReview != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFB71C1C),
                                side: const BorderSide(color: Color(0xFFB71C1C)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              onPressed: _isSubmitting
                                  ? null
                                  : () async {
                                      final navigator = Navigator.of(sheetContext);
                                      final messenger = ScaffoldMessenger.of(context);
                                      final authProvider = context.read<AuthProvider>();
                                      final currentUserId = currentUser.id;
                                      final authToken = auth.token;

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Eliminar reseña'),
                                          content: const Text('¿Quieres borrar tu reseña?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(dialogContext).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(dialogContext).pop(true),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed != true) return;
                                      setState(() {
                                        _isSubmitting = true;
                                      });
                                      try {
                                        await _eventService.deleteEventReview(
                                          eventId: widget.event.id,
                                          userId: currentUserId,
                                          token: authToken,
                                        );
                                        if (!mounted) return;
                                        await authProvider.refreshProfileStats();
                                        navigator.pop(true);
                                      } catch (e) {
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          SnackBar(content: Text('No se pudo eliminar la reseña: $e')),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isSubmitting = false;
                                          });
                                        }
                                      }
                                    },
                              child: const Text('Eliminar reseña'),
                            ),
                          ),
                        ],
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

    if (result == true) {
      await _loadReviews();
    }
  }

  Future<void> _deleteReview(EventReview review) async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.user;
    if (currentUser == null || review.userId != currentUser.id) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Quieres borrar tu reseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _eventService.deleteEventReview(
        eventId: widget.event.id,
        userId: currentUser.id,
        token: auth.token,
      );
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfileStats();
      await _loadReviews();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la reseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.user;
    final currentUserReview = _currentUserReview(currentUser?.id);
    final attended = currentUser != null && currentUser.attendedEvents.contains(widget.event.id);
    final canReview = attended && _hasEventPassed;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EB),
        title: const Text('Reseñas del evento'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8DED2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B1B1B)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFCD116), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _reviews.isEmpty ? 'Sin calificaciones aún' : _averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '• ${_reviews.length} reseñas',
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      canReview
                          ? currentUserReview == null
                              ? 'Ya puedes dejar tu opinión sobre este evento.'
                              : 'Tienes una reseña publicada. Puedes editarla si lo deseas.'
                          : attended
                              ? 'Tu reseña estará disponible cuando el evento haya pasado.'
                              : 'Solo pueden reseñar quienes asistieron al evento.',
                      style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    if (canReview)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF078930),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: _isSubmitting ? null : () => _openReviewForm(existingReview: currentUserReview),
                          icon: Icon(currentUserReview == null ? Icons.rate_review_outlined : Icons.edit_outlined),
                          label: Text(currentUserReview == null ? 'Añadir reseña' : 'Editar mi reseña'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                _EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'No pudimos cargar las reseñas',
                  message: _errorMessage!,
                  actionLabel: 'Reintentar',
                  onAction: _loadReviews,
                )
              else if (_reviews.isEmpty)
                _EmptyState(
                  icon: Icons.reviews_outlined,
                  title: 'Todavía no hay reseñas',
                  message: canReview
                      ? 'Sé la primera persona en compartir cómo fue el evento.'
                      : 'Cuando haya reseñas aparecerán aquí.',
                  actionLabel: canReview ? (currentUserReview == null ? 'Añadir reseña' : 'Editar mi reseña') : null,
                  onAction: canReview ? () => _openReviewForm(existingReview: currentUserReview) : null,
                )
              else
                Column(
                  children: [
                    ..._reviews.map((review) {
                      final isMine = currentUser != null && review.userId == currentUser.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReviewCard(
                          review: review,
                          isMine: isMine,
                          onEdit: isMine && canReview ? () => _openReviewForm(existingReview: review) : null,
                          onDelete: isMine ? () => _deleteReview(review) : null,
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isMine,
    this.onEdit,
    this.onDelete,
  });

  final EventReview review;
  final bool isMine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw).toLocal();
      return DateFormat('d MMM yyyy', 'es').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DED2)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEAF6EC),
                backgroundImage: review.profilePictureUrl.isNotEmpty ? NetworkImage(review.profilePictureUrl) : null,
                child: review.profilePictureUrl.isEmpty
                    ? const Icon(Icons.person, color: Color(0xFF078930))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.userName.isNotEmpty ? review.userName : 'Usuario anónimo',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1D)),
                          ),
                        ),
                        if (isMine)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF6EC),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Tu reseña',
                              style: TextStyle(
                                color: Color(0xFF078930),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final active = index < review.star;
                        return Icon(
                          active ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 18,
                          color: const Color(0xFFFCD116),
                        );
                      }),
                    ),
                    if (review.createdAt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.reviewText,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF595959)),
          ),
          if (isMine && (onEdit != null || onDelete != null)) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFB71C1C)),
                    label: const Text('Eliminar'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DED2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF078930)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1D)),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF078930),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
