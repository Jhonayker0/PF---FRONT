import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/event.dart';
import 'providers/auth_provider.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

class EventosBarranquillaApp extends StatelessWidget {
  const EventosBarranquillaApp({super.key});

  static const Color _background = Color(0xFFF6F1E8);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _ink = Color(0xFF181818);
  static const Color _muted = Color(0xFF6B645C);
  static const Color _accent = Color(0xFFDB6B2F);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
      surface: _surface,
    ).copyWith(
      primary: _accent,
      secondary: _ink,
      surface: _surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _ink,
      outline: const Color(0xFFE6DDD2),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Eventos Barranquilla',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _background,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 40,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: _muted,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: _muted,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _ink,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE7DFD4)),
          ),
        ),
      ),
      routerConfig: _buildRouter(),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isLoggedIn = authProvider.isAuthenticated;

        // If user is logged in and trying to access auth pages, redirect to home
        if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
          return '/home';
        }

        // If user is not logged in and trying to access protected pages, redirect to login
        if (!isLoggedIn && state.matchedLocation != '/' && state.matchedLocation != '/login' && state.matchedLocation != '/register') {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return _ScaffoldWithBottomNav(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/event-detail',
          builder: (context, state) {
            final extra = state.extra;
            Event event;
            String? heroTag;
            if (extra is Map) {
              event = extra['event'] as Event;
              heroTag = extra['heroTag'] as String?;
            } else {
              event = extra as Event;
            }
            return EventDetailScreen(event: event, heroTag: heroTag);
          },
        ),
        GoRoute(
          path: '/create-event',
          builder: (context, state) => const CreateEventScreen(),
        ),
      ],
    );
  }
}

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({required this.child});

  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith('/favorites')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 1:
              context.go('/favorites');
              break;
            case 2:
              context.go('/profile');
              break;
            default:
              context.go('/home');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}