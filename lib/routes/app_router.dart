import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/district/district_screen.dart';
import '../screens/tour/tour_details_screen.dart';
import '../screens/location/add_location_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/district/:districtId',
        name: 'district',
        builder: (context, state) {
          final districtId = state.pathParameters['districtId']!;
          return DistrictScreen(districtId: districtId);
        },
      ),
      GoRoute(
        path: '/tour/:tourId',
        name: 'tour-details',
        builder: (context, state) {
          final tourId = state.pathParameters['tourId']!;
          return TourDetailsScreen(tourId: tourId);
        },
      ),
      GoRoute(
        path: '/add-location',
        name: 'add-location',
        builder: (context, state) => const AddLocationScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
