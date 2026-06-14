import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/auth_repository.dart';
import '../features/login/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/house/add_house_screen.dart';
import '../features/house/edit_house_screen.dart';
import '../features/house/detail_house_screen.dart';
import '../features/search/search_screen.dart';
import '../features/public/landing_screen.dart';
import '../features/map/admin_map_screen.dart';
import '../features/map/public_map_screen.dart';
import '../features/house/public_detail_house_screen.dart';
import '../data/house_model.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      refreshListenable: authRepository,
      redirect: (context, state) {
        final isAuthenticated = authRepository.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        
        // Define protected routes
        final isProtectedRoute = state.matchedLocation.startsWith('/admin') || 
                                 state.matchedLocation.startsWith('/add-house') ||
                                 state.matchedLocation.startsWith('/edit-house');

        if (!isAuthenticated && isProtectedRoute) {
          return '/login';
        }

        if (isAuthenticated && isLoggingIn) {
          return '/admin';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/add-house',
          builder: (context, state) => const AddHouseScreen(),
        ),
        GoRoute(
          path: '/detail-house',
          builder: (context, state) {
            final house = state.extra as HouseModel;
            return DetailHouseScreen(house: house);
          },
        ),
        GoRoute(
          path: '/edit-house',
          builder: (context, state) {
            final house = state.extra as HouseModel;
            return EditHouseScreen(house: house);
          },
        ),
        GoRoute(
          path: '/admin-map',
          builder: (context, state) => const AdminMapScreen(),
        ),
        GoRoute(
          path: '/public-map',
          builder: (context, state) => const PublicMapScreen(),
        ),
        GoRoute(
          path: '/house/:kode',
          builder: (context, state) {
            final kode = state.pathParameters['kode'] ?? '';
            return PublicDetailHouseScreen(kodeRumah: kode);
          },
        ),
      ],
    );
  }
}
