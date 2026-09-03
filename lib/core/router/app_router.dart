import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import screens
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/patient_search/presentation/search_screen.dart';
import '../../features/patient_record/presentation/patient_record_screen.dart';
import '../../features/consultation/presentation/consultation_screen.dart';
import '../../features/consultation/presentation/consultation_history_screen.dart';
import '../../features/consultation/presentation/treatments_screen.dart';
import '../../features/cardiac_analysis/presentation/cardiac_analysis_screen.dart';
import '../../features/vaccination/presentation/vaccination_screen.dart';
import '../../features/patient_search/presentation/new_patient_screen.dart';
import '../../features/patient_search/presentation/edit_patient_screen.dart';
import '../../features/queue/presentation/queue_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// Route names for SANTÉ+ TOGO
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String search = '/search';
  static const String newPatient = '/patient/new';
  static const String patient = '/patient/:id';
  static const String editPatient = '/patient/:id/edit';
  static const String consultation = '/patient/:id/consultation';
  static const String consultationHistory = '/patient/:id/history';
  static const String treatments = '/patient/:id/treatments';
  static const String cardiacAnalysis = '/patient/:id/cardiac-analysis';
  static const String vaccinations = '/patient/:id/vaccinations';
  static const String queue = '/queue';
  static const String settings = '/settings';
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

        // New patient route (must be declared before the /patient/:id route)
        GoRoute(
          path: AppRoutes.newPatient,
          name: 'newPatient',
          builder: (context, state) => const NewPatientScreen(),
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

        // Edit patient route
        GoRoute(
          path: AppRoutes.editPatient,
          name: 'editPatient',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            return EditPatientScreen(patientId: patientId);
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

        // Consultation history route
        GoRoute(
          path: AppRoutes.consultationHistory,
          name: 'consultationHistory',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            return ConsultationHistoryScreen(patientId: patientId);
          },
        ),

        // Active treatments route
        GoRoute(
          path: AppRoutes.treatments,
          name: 'treatments',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            return TreatmentsScreen(patientId: patientId);
          },
        ),

        // Cardiac analysis route (CardioBeat)
        GoRoute(
          path: AppRoutes.cardiacAnalysis,
          name: 'cardiacAnalysis',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            final consultationId = state.uri.queryParameters['consultationId'];
            return CardiacAnalysisScreen(
              patientId: patientId,
              consultationId: consultationId,
            );
          },
        ),

        // Vaccination calendar route
        GoRoute(
          path: AppRoutes.vaccinations,
          name: 'vaccinations',
          builder: (context, state) {
            final patientId = state.pathParameters['id'] ?? '';
            return VaccinationScreen(patientId: patientId);
          },
        ),

        // Queue route
        GoRoute(
          path: AppRoutes.queue,
          name: 'queue',
          builder: (context, state) => const QueueScreen(),
        ),

        // Settings route
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}

/// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
