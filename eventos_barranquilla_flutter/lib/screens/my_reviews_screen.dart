import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_review_entry.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final EventService _eventService = EventService();
  bool _isLoading = true;
  String? _errorMessage;
  List<UserReviewEntry> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadMyReviews();
  }

  Future<void> _loadMyReviews() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() {
        _errorMessage = 'Debes iniciar sesión para ver tus reseñas.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews = await _eventService.fetchReviewsGivenByUser(user.id);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudieron cargar tus reseñas: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F3),
        title: const Text('Mis reseñas'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyReviews,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8E0D7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reseñas que has dejado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1A17),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aquí puedes revisar todas tus opiniones sobre eventos.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              _EmptyMessage(
                icon: Icons.error_outline_rounded,
                title: 'No pudimos cargar tus reseñas',
                message: _errorMessage!,
                actionLabel: 'Reintentar',
                onAction: _loadMyReviews,
              )
            else if (_reviews.isEmpty)
              const _EmptyMessage(
                icon: Icons.reviews_outlined,
                title: 'Aún no has dejado reseñas',
                message: 'Cuando escribas opiniones sobre eventos, aparecerán aquí.',
              )
            else
              ..._reviews.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MyReviewCard(entry: entry),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MyReviewCard extends StatelessWidget {
  const _MyReviewCard({required this.entry});

  final UserReviewEntry entry;

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.eventTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1A17),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.eventLocation,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final active = index < entry.review.star;
              return Icon(
                active ? Icons.star_rounded : Icons.star_outline_rounded,
                color: const Color(0xFF078930),
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            entry.review.reviewText,
            style: const TextStyle(height: 1.45, color: Color(0xFF5E554C)),
          ),
          if (entry.review.createdAt.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _formatDate(entry.review.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0D7)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF078930)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
