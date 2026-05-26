import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/smart_id_card.dart';
import '../providers/auth_provider.dart';
import '../services/smart_id_service.dart';

class SmartIdUsuarioScreen extends StatefulWidget {
  const SmartIdUsuarioScreen({super.key});

  @override
  State<SmartIdUsuarioScreen> createState() => _SmartIdUsuarioScreenState();
}

class _SmartIdUsuarioScreenState extends State<SmartIdUsuarioScreen>
    with SingleTickerProviderStateMixin {
  final SmartIdService _smartIdService = SmartIdService();
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Timer _clockTimer;

  Future<SmartIdCard>? _smartIdFuture;
  String? _loadedUserId;
  bool _showBack = false;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addStatusListener((status) {
      if ((status == AnimationStatus.completed || status == AnimationStatus.dismissed) && mounted) {
        setState(() {
          _showBack = !_showBack;
        });
      }
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      _smartIdFuture = null;
      _loadedUserId = null;
      return;
    }

    if (_loadedUserId != user.id) {
      _loadedUserId = user.id;
      _smartIdFuture = _smartIdService.fetchSmartId(
        userId: user.id,
        token: auth.token,
      );
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCard() async {
    if (_controller.isAnimating) return;
    if (_showBack) {
      await _controller.reverse();
    } else {
      await _controller.forward();
    }
  }

  String _formatDateTime(DateTime value) {
    const dayNames = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const monthNames = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    final dayName = dayNames[value.weekday - 1];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$dayName, ${monthNames[value.month - 1]} ${value.day} ${value.year}\n$hour:$minute:$second';
  }

  Widget _buildFrontCard({required AuthProvider auth}) {
    final user = auth.user!;
    final parts = user.name.trim().split(RegExp(r'\s+'));
    final initials = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first.substring(0, 1).toUpperCase()
        : 'U';

    return _SmartIdShell(
      backgroundColor: const Color(0xFFda141c),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: ClipPath(
              clipper: _DiagonalCornerClipper(),
              child: Container(width: 175, height: 230, color: Colors.white.withValues(alpha: 0.95)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatDateTime(_now),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 182, 182, 182),
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 72,
                    backgroundColor: const Color(0xFFF0EDE7),
                    backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                        ? NetworkImage(user.profilePicture!)
                        : null,
                    child: user.profilePicture == null || user.profilePicture!.isEmpty
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A2B89),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 239, 238, 238),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.isAdmin ? 'Organizador' : 'Usuario',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 182, 182, 182),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                Image.asset(
                  'assets/CumbeLogoBlanco.png',
                  width: 146,
                  fit: BoxFit.contain,
                ),
                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    const Text(
                      'Toca para girar',
                      style: TextStyle(
                        color: Color(0xFFE7E0D8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(SmartIdCard smartId) {
    return _SmartIdShell(
      backgroundColor: const Color(0xFFF8F6F1),
      child: Stack(
        children: [
          Positioned(
            top: 26,
            left: 22,
            right: 22,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Smart City ID',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.32),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 90, 24, 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: smartId.qrCodeBase64 != null && smartId.qrCodeBase64!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              base64Decode(smartId.qrCodeBase64!.split(',').last),
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        : QrImageView(
                            data: smartId.qrContent,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF121212),
                            ),
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF121212),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Este código es personal e intransferible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.68),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Su uso está pensado para integrarse al proyecto Smart City de Cumbé.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.48),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Toca para volver',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2EC),
        title: const Text('Smart ID'),
      ),
      body: SafeArea(
        child: Center(
          child: user == null
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Debes iniciar sesión para ver tu identificación.',
                    textAlign: TextAlign.center,
                  ),
                )
              : FutureBuilder<SmartIdCard>(
                  future: _smartIdFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                      return const SizedBox(
                        width: 160,
                        height: 160,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No se pudo cargar tu Smart ID.\n${snapshot.error ?? ''}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final smartId = snapshot.data!;

                    return GestureDetector(
                      onTap: _toggleCard,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final angle = _animation.value * math.pi;
                          final showFront = angle <= (math.pi / 2);

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0015)
                              ..rotateY(angle),
                            child: showFront
                                ? _buildFrontCard(auth: auth)
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(math.pi),
                                    child: _buildBackCard(smartId),
                                  ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SmartIdShell extends StatelessWidget {
  const _SmartIdShell({required this.child, required this.backgroundColor});

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.62,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _DiagonalCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
