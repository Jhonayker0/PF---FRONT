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
import 'screens/my_events_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/event_reviews_screen.dart';
import 'screens/my_reviews_screen.dart';
import 'screens/smart_id_usuario.dart';
import 'screens/scan_payment_screen.dart';

class EventosBarranquillaApp extends StatelessWidget {
  const EventosBarranquillaApp({super.key});

  static const Color _green = Color(0xFF078930);
  static const Color _yellow = Color(0xFFFCD116);
  static const Color _red = Color(0xFFCE1126);
  static const Color _background = Color(0xFFF9F5EA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _ink = Color(0xFF181818);
  static const Color _muted = Color(0xFF6B645C);
  static const Color _accent = _green;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
      surface: _surface,
    ).copyWith(
      primary: _accent,
      secondary: _red,
      tertiary: _yellow,
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
              side: const BorderSide(color: Color(0xFFE1DCCF)),
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
              path: '/my-events',
              builder: (context, state) => const MyEventsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/profile/edit',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/my-reviews',
              builder: (context, state) => const MyReviewsScreen(),
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
        GoRoute(
          path: '/smart-id-usuario',
          builder: (context, state) => const SmartIdUsuarioScreen(),
        ),
        GoRoute(
          path: '/event-reviews',
          builder: (context, state) {
            final extra = state.extra;
            final event = extra as Event;
            return EventReviewsScreen(event: event);
          },
        ),
        GoRoute(
          path: '/scan-payment',
          builder: (context, state) => const ScanPaymentScreen(),
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
    if (location.startsWith('/my-events')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;
    final showCreateButton = currentIndex == 0 && isAdmin;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: showCreateButton
          ? FloatingActionButton(
              onPressed: () => context.go('/create-event'),
              backgroundColor: EventosBarranquillaApp._green,
              foregroundColor: Colors.white,
              elevation: 6,
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: EventosBarranquillaApp._green,
        unselectedItemColor: const Color(0xFF8A847D),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          switch (index) {
            case 1:
              context.go('/favorites');
              break;
            case 2:
              context.go('/my-events');
              break;
            case 3:
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
            icon: Icon(Icons.event_note_outlined),
            label: 'Mis eventos',
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