import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import screens
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/patient_search/presentation/search_screen.dart';
import '../../features/patient_record/presentation/patient_record_screen.dart';
import '../../features/consultation/presentation/consultation_screen.dart';
import '../../features/queue/presentation/queue_screen.dart';

/// Route names for SANTÉ+ TOGO
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String search = '/search';
  static const String patient = '/patient/:id';
  static const String consultation = '/patient/:id/consultation';
  static const String queue = '/queue';
}

/// Router configuration for SANTÉ+ TOGO
///
/// Uses go_router for navigation with named routes.
/// This will be updated as screens are implemented.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        // Login route
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Home route
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Search route
        GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),

        // Patient record route
        GoRoute(
          path: AppRoutes.patient,
          name: 'patient',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            return PatientRecordScreen(patientId: patientId);
          },
        ),

        // Consultation route
        GoRoute(
          path: AppRoutes.consultation,
          name: 'consultation',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            return ConsultationScreen(patientId: patientId);
          },
        ),

        // Queue route
        GoRoute(
          path: AppRoutes.queue,
          name: 'queue',
          builder: (context, state) => const QueueScreen(),
        ),
      ],
    );
  }
}

/// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
