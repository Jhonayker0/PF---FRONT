import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: const [
            _ProfileHeader(),
            SizedBox(height: 20),
            _ProfileMenuItem(
              text: 'Mi cuenta',
              icon: Icons.person_outline,
            ),
            _ProfileMenuItem(
              text: 'Notificaciones',
              icon: Icons.notifications_none,
            ),
            _ProfileMenuItem(
              text: 'Configuracion',
              icon: Icons.settings_outlined,
            ),
            _ProfileMenuItem(
              text: 'Centro de ayuda',
              icon: Icons.help_outline,
            ),
            _ProfileMenuItem(
              text: 'Cerrar sesion',
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 58,
              backgroundImage: NetworkImage(
                'https://i.postimg.cc/0jqKB6mS/Profile-Image.png',
              ),
            ),
            Positioned(
              right: -6,
              bottom: 0,
              child: SizedBox(
                height: 42,
                width: 42,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: ProfileScreen._surface,
                    side: const BorderSide(color: ProfileScreen._border),
                  ),
                  onPressed: () {},
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: ProfileScreen._primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Usuario',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ProfileScreen._textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'usuario@email.com',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ProfileScreen._textMuted,
              ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.text,
    required this.icon,
    this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(18),
            foregroundColor: ProfileScreen._primary,
            backgroundColor: ProfileScreen._surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: ProfileScreen._border),
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
              Icon(icon, color: ProfileScreen._primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ProfileScreen._textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
                color: ProfileScreen._textPrimary.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
