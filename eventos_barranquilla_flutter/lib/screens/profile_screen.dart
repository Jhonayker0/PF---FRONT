import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/profile_stats.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const Color _background = Color(0xFFFDF8F3);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFFD4111A);
  static const Color _textPrimary = Color(0xFF1F1A17);
  static const Color _textMuted = Color(0xFF7A6E65);
  static const Color _border = Color(0xFFE8E0D7);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isAuthenticated;
        final user = isLoggedIn ? authProvider.user : null;
        final stats = isLoggedIn ? authProvider.profileStats : null;
        final roleLabel = user?.isAdmin == true ? 'Organizador' : 'Usuario';
        final trimmedName = user?.name.trim() ?? '';
        final avatarLetter = trimmedName.isNotEmpty
            ? trimmedName.substring(0, 1).toUpperCase()
            : 'U';

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: _textPrimary,
            elevation: 0,
            title: const Text('Perfil'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                if (isLoggedIn) ...[
                  _ProfileHeaderCard(
                    name: user!.name,
                    roleLabel: roleLabel,
                    avatarLetter: avatarLetter,
                    profilePictureUrl: user.profilePicture,
                    stats: stats!,
                  ),
                  const SizedBox(height: 20),
                  const _ProfileQuickActions(),
                  const SizedBox(height: 16),
                  if (user?.isAdmin == true) const _ProfilePromoCard(),
                  const SizedBox(height: 18),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No has iniciado sesión',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicia sesión para ver tu perfil, tus estadísticas y tus opciones personalizadas.',
                          style: TextStyle(color: _textMuted, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Ir al login'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _ProfileListItem(
                  text: 'Configuracion de cuenta',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    final auth = context.read<AuthProvider>();
                    if (auth.isAuthenticated) {
                      context.go('/profile/edit');
                    } else {
                      context.go('/login');
                    }
                  },
                ),
                const _ProfileListItem(text: 'Ayuda', icon: Icons.help_outline),
                const _ProfileListItem(
                  text: 'Ver perfil',
                  icon: Icons.person_outline,
                ),
                const _ProfileListItem(
                  text: 'Privacidad',
                  icon: Icons.privacy_tip_outlined,
                ),
                const SizedBox(height: 10),
                const _ProfileListItem(
                  text: 'Referir organizador',
                  icon: Icons.group_outlined,
                ),
                const _ProfileListItem(
                  text: 'Encuentra coanfitrion',
                  icon: Icons.groups_2_outlined,
                ),
                const _ProfileListItem(
                  text: 'Legal',
                  icon: Icons.menu_book_outlined,
                ),
                if (isLoggedIn)
                  _ProfileListItem(
                    text: 'Cerrar sesion',
                    icon: Icons.logout,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text(
                            '¿Estás seguro de que deseas cerrar sesión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await context.read<AuthProvider>().signOut();
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                                if (context.mounted) {
                                  context.go('/');
                                }
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.roleLabel,
    required this.avatarLetter,
    required this.profilePictureUrl,
    required this.stats,
  });

  final String name;
  final String roleLabel;
  final String avatarLetter;
  final String? profilePictureUrl;
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ProfileScreen._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ProfileScreen._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFFF3E6D8),
                    backgroundImage: profilePictureUrl != null &&
                            profilePictureUrl!.isNotEmpty
                        ? NetworkImage(profilePictureUrl!)
                        : null,
                    child: profilePictureUrl == null ||
                            profilePictureUrl!.isEmpty
                        ? Text(
                            avatarLetter,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8E4A1F),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -4,
                    bottom: -2,
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: ProfileScreen._primary,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: ProfileScreen._surface),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ProfileScreen._textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roleLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ProfileScreen._textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _ProfileStat(value: '${stats.events}', label: 'Eventos'),
                const SizedBox(height: 10),
                const Divider(height: 1, color: ProfileScreen._border),
                const SizedBox(height: 10),
                _ProfileStat(value: '${stats.reviews}', label: 'Reseñas'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: ProfileScreen._textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ProfileScreen._textMuted),
        ),
      ],
    );
  }
}

class _ProfileQuickActions extends StatelessWidget {
  const _ProfileQuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _ProfileActionCard(
            title: 'Eventos pasados',
            badgeText: 'Nuevo',
            icon: Icons.history,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _ProfileActionCard(
            title: 'Conexiones',
            badgeText: 'Nuevo',
            icon: Icons.group_outlined,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.title,
    required this.badgeText,
    required this.icon,
  });

  final String title;
  final String badgeText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProfileScreen._surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfileScreen._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ProfileScreen._border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ProfileScreen._textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: ProfileScreen._textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 16,
              color: ProfileScreen._textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePromoCard extends StatelessWidget {
  const _ProfilePromoCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileScreen._surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go('/create-event'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ProfileScreen._border),
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_people,
                  color: ProfileScreen._primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conviertete en anfitrion',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        color: ProfileScreen._textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca aquí para crear tu próximo evento.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ProfileScreen._textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ProfileScreen._textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({required this.text, required this.icon, this.onTap});

  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: ProfileScreen._textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: ProfileScreen._textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ProfileScreen._textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: ProfileScreen._textMuted),
          ],
        ),
      ),
    );
  }
}
