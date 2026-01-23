import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/dev_screen_label.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/nutrition/presentation/pages/nutrition_page.dart';
import '../../features/nutrition/presentation/pages/food_search_page.dart';
import '../../features/nutrition/presentation/pages/barcode_scanner_page.dart';
import '../../features/nutrition/presentation/pages/recent_meals_page.dart';
import '../../features/nutrition/presentation/pages/ai_suggestion_page.dart';
import '../../features/organization/presentation/pages/org_selector_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/progress/presentation/pages/register_weight_page.dart';
import '../../features/progress/presentation/pages/register_measurements_page.dart';
import '../../features/progress/presentation/pages/weight_goal_page.dart';
import '../../features/progress/presentation/pages/progress_stats_page.dart';
import '../../features/progress/presentation/pages/photo_comparison_page.dart';
import '../../features/progress/presentation/pages/progress_comparison_page.dart';
import '../../features/progress/presentation/pages/progress_report_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/workout/presentation/pages/workout_detail_page.dart';
import '../../features/workout/presentation/pages/workouts_page.dart';
import '../../features/workout/presentation/pages/plan_detail_page.dart';
import '../../features/workout/presentation/pages/waiting_for_trainer_page.dart';
import '../../features/training_plan/presentation/pages/plan_wizard_page.dart';
import '../../features/workout_builder/presentation/pages/workout_from_scratch_page.dart';
import '../../features/workout_builder/presentation/pages/workout_with_ai_page.dart';
import '../../features/workout_builder/presentation/pages/workout_templates_page.dart';
import '../../features/workout_builder/presentation/pages/workout_progression_page.dart';
import '../../features/workout_builder/presentation/pages/workout_builder_page.dart';
import '../../features/workout_builder/presentation/pages/exercise_form_page.dart';
import '../../features/checkin/presentation/pages/checkin_page.dart';
import '../../features/checkin/presentation/pages/checkin_history_page.dart';
import '../../features/checkin/presentation/pages/qr_scanner_page.dart';
import '../../features/checkin/presentation/pages/qr_generator_page.dart';
import '../../features/gamification/presentation/pages/leaderboard_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/billing/presentation/pages/billing_dashboard_page.dart';
import '../../features/coach/presentation/pages/coach_dashboard_page.dart';
import '../../features/active_workout/presentation/pages/active_workout_page.dart';
import '../../features/shared_session/presentation/pages/shared_session_page.dart';
import '../../features/legal/presentation/pages/about_page.dart';
import '../../features/legal/presentation/pages/privacy_page.dart';
import '../../features/legal/presentation/pages/terms_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/social/presentation/pages/activity_feed_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/organization/presentation/pages/create_org_page.dart';
import '../../features/organization/presentation/pages/join_org_page.dart';
import '../../features/trainer_home/presentation/pages/trainer_home_page.dart';
import '../../features/nutritionist_home/presentation/pages/nutritionist_home_page.dart';
import '../../features/gym_home/presentation/pages/gym_home_page.dart';
import '../../features/auth/presentation/pages/invite_accept_page.dart';
import '../../features/trainer_workout/presentation/pages/students_list_page.dart';
import '../../features/trainer_workout/presentation/pages/student_workouts_page.dart';
import '../../features/students/presentation/pages/student_detail_page.dart';
import '../../features/students/presentation/pages/student_plan_history_page.dart';
import '../../features/trainer_workout/presentation/pages/trainer_student_progress_page.dart';
import '../../features/trainer_workout/presentation/pages/trainer_plans_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/schedule/presentation/pages/student_schedule_page.dart';
import '../../features/nutrition/presentation/pages/patients_list_page.dart';
import '../../features/nutrition/presentation/pages/diet_plans_list_page.dart';
import '../../features/gym/presentation/pages/staff_management_page.dart';
import '../../shared/presentation/wrappers/role_chat_wrapper.dart';
import '../../core/domain/entities/user_role.dart';
import '../../features/gym/presentation/pages/members_list_page.dart';
import '../../features/gym/presentation/pages/gym_settings_page.dart';
import '../../features/gym/presentation/pages/gym_reports_page.dart';
import '../../features/gym/presentation/pages/trainers_management_page.dart';
import '../../features/nutrition/presentation/pages/patient_diet_plan_page.dart';
import '../../features/nutrition/presentation/pages/diet_plan_builder_page.dart';
import '../../features/nutrition/presentation/pages/meal_log_page.dart';
import '../../features/nutrition/presentation/pages/patient_detail_page.dart';
import '../../features/nutrition/presentation/pages/nutrition_summary_page.dart';
import '../../features/nutrition_builder/presentation/pages/nutrition_builder_page.dart';
import '../../features/checkin/presentation/pages/smart_checkin_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/home/presentation/providers/student_home_provider.dart';
import '../../shared/presentation/layouts/main_scaffold.dart';
import '../../core/providers/context_provider.dart';
import 'route_names.dart';

/// Wraps a widget with DevScreenLabel for debug/dev screen identification
Widget _devLabel(String name, Widget child) {
  return DevScreenLabel(screenName: name, child: child);
}

/// Guard redirect for workout creation routes
/// Returns redirect path if student has a trainer, null otherwise
/// Trainers are never redirected - this guard is for students only
String? _trainerGuardRedirect(BuildContext context) {
  try {
    final container = ProviderScope.containerOf(context);

    // Check if user is a trainer - trainers should never be redirected
    final activeContext = container.read(activeContextProvider);
    if (activeContext?.isTrainer == true) {
      return null; // Trainers can access all workout creation routes
    }

    final hasTrainer = container.read(studentDashboardProvider).hasTrainer;
    if (hasTrainer) {
      // Redirect to workouts list if student has a trainer
      return RouteNames.workouts;
    }
  } catch (_) {
    // If provider not available (e.g., not logged in), allow access
  }
  return null;
}

/// App Router Configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.welcome,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: RouteNames.welcome,
        name: 'welcome',
        builder: (context, state) => _devLabel('welcome', const WelcomePage()),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => _devLabel('login', const LoginPage()),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => _devLabel('register', const RegisterPage()),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => _devLabel('forgot-password', const ForgotPasswordPage()),
      ),
      GoRoute(
        path: RouteNames.orgSelector,
        name: 'org-selector',
        builder: (context, state) => _devLabel('org-selector', const OrgSelectorPage()),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home/Dashboard branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: 'home',
                builder: (context, state) => _devLabel('home', const HomePage()),
              ),
            ],
          ),

          // Workouts branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.workouts,
                name: 'workouts',
                builder: (context, state) => _devLabel('workouts', const WorkoutsPage()),
                routes: [
                  // Specific routes MUST come before :workoutId
                  // Note: These routes are protected by hasTrainer check
                  GoRoute(
                    path: 'builder',
                    name: 'workout-builder',
                    redirect: (context, state) => _trainerGuardRedirect(context),
                    builder: (context, state) => _devLabel('workout-builder', const WorkoutBuilderPage()),
                  ),
                  GoRoute(
                    path: 'from-scratch',
                    name: 'workout-from-scratch',
                    redirect: (context, state) => _trainerGuardRedirect(context),
                    builder: (context, state) => _devLabel('workout-from-scratch', const WorkoutFromScratchPage()),
                  ),
                  GoRoute(
                    path: 'with-ai',
                    name: 'workout-with-ai',
                    redirect: (context, state) => _trainerGuardRedirect(context),
                    builder: (context, state) => _devLabel('workout-with-ai', const WorkoutWithAIPage()),
                  ),
                  GoRoute(
                    path: 'templates',
                    name: 'workout-templates',
                    redirect: (context, state) => _trainerGuardRedirect(context),
                    builder: (context, state) => _devLabel('workout-templates', WorkoutTemplatesPage(
                      initialCategory: state.uri.queryParameters['category'],
                    )),
                  ),
                  GoRoute(
                    path: 'progression',
                    name: 'workout-progression',
                    builder: (context, state) => _devLabel('workout-progression', const WorkoutProgressionPage()),
                  ),
                  GoRoute(
                    path: 'exercises/new',
                    name: 'exercise-create',
                    builder: (context, state) => _devLabel('exercise-create', const ExerciseFormPage()),
                  ),
                  // Dynamic route MUST come last
                  GoRoute(
                    path: ':workoutId',
                    name: 'workout-detail',
                    builder: (context, state) => _devLabel('workout-detail', WorkoutDetailPage(
                      workoutId: state.pathParameters['workoutId'] ?? '',
                    )),
                  ),
                ],
              ),
            ],
          ),

          // Nutrition branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nutrition,
                name: 'nutrition',
                builder: (context, state) => _devLabel('nutrition', const NutritionPage()),
              ),
            ],
          ),

          // Progress branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.progress,
                name: 'progress',
                builder: (context, state) => _devLabel('progress', const ProgressPage()),
              ),
            ],
          ),

          // Chat branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.chat,
                name: 'chat',
                builder: (context, state) => _devLabel('chat', const ChatPage()),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes (no bottom nav)
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => _devLabel('profile', const ProfilePage()),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        name: 'edit-profile',
        builder: (context, state) => _devLabel('edit-profile', const EditProfilePage()),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => _devLabel('settings', const SettingsPage()),
      ),
      GoRoute(
        path: RouteNames.planWizard,
        name: 'plan-wizard',
        redirect: (context, state) {
          // Only guard if no studentId (student creating for themselves)
          final studentId = state.uri.queryParameters['studentId'];
          if (studentId != null) return null; // Trainer creating for student
          return _trainerGuardRedirect(context);
        },
        builder: (context, state) {
          final studentId = state.uri.queryParameters['studentId'];
          final planId = state.uri.queryParameters['edit'];
          final basePlanId = state.uri.queryParameters['basePlanId'];
          final phaseType = state.uri.queryParameters['phaseType'];
          return _devLabel('plan-wizard', PlanWizardPage(
            studentId: studentId,
            planId: planId,
            basePlanId: basePlanId,
            phaseType: phaseType,
          ));
        },
      ),
      GoRoute(
        path: RouteNames.planDetail,
        name: 'plan-detail',
        redirect: (context, state) {
          final planId = state.pathParameters['planId'];
          // Redirect to workouts if planId is null, empty, or literal "null"
          if (planId == null || planId.isEmpty || planId == 'null') {
            return RouteNames.workouts;
          }
          return null;
        },
        builder: (context, state) => _devLabel('plan-detail', PlanDetailPage(
          planId: state.pathParameters['planId'] ?? '',
        )),
      ),
      GoRoute(
        path: RouteNames.checkin,
        name: 'checkin',
        builder: (context, state) => _devLabel('checkin', const CheckinPage()),
      ),
      GoRoute(
        path: RouteNames.checkinHistory,
        name: 'checkin-history',
        builder: (context, state) => _devLabel('checkin-history', const CheckinHistoryPage()),
      ),
      GoRoute(
        path: RouteNames.qrScanner,
        name: 'qr-scanner',
        builder: (context, state) => _devLabel('qr-scanner', const QrScannerPage()),
      ),
      GoRoute(
        path: RouteNames.qrGenerator,
        name: 'qr-generator',
        builder: (context, state) => _devLabel('qr-generator', const QrGeneratorPage()),
      ),
      GoRoute(
        path: RouteNames.leaderboard,
        name: 'leaderboard',
        builder: (context, state) => _devLabel('leaderboard', const LeaderboardPage()),
      ),
      GoRoute(
        path: RouteNames.billing,
        name: 'billing',
        builder: (context, state) => _devLabel('billing', const BillingDashboardPage()),
      ),
      GoRoute(
        path: RouteNames.coachDashboard,
        name: 'coach-dashboard',
        builder: (context, state) => _devLabel('coach-dashboard', const CoachDashboardPage()),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => _devLabel('notifications', const NotificationsPage()),
      ),
      GoRoute(
        path: RouteNames.marketplace,
        name: 'marketplace',
        builder: (context, state) => _devLabel('marketplace', const MarketplacePage()),
      ),
      GoRoute(
        path: RouteNames.activityFeed,
        name: 'activity-feed',
        builder: (context, state) => _devLabel('activity-feed', const ActivityFeedPage()),
      ),
      GoRoute(
        path: RouteNames.help,
        name: 'help',
        builder: (context, state) => _devLabel('help', const HelpPage()),
      ),

      // Progress routes
      GoRoute(
        path: '/progress/weight',
        name: 'register-weight',
        builder: (context, state) => _devLabel('register-weight', const RegisterWeightPage()),
      ),
      GoRoute(
        path: RouteNames.measurements,
        name: 'register-measurements',
        builder: (context, state) => _devLabel('register-measurements', const RegisterMeasurementsPage()),
      ),
      GoRoute(
        path: RouteNames.weightGoal,
        name: 'weight-goal',
        builder: (context, state) => _devLabel('weight-goal', const WeightGoalPage()),
      ),
      GoRoute(
        path: RouteNames.progressStats,
        name: 'progress-stats',
        builder: (context, state) => _devLabel('progress-stats', const ProgressStatsPage()),
      ),
      GoRoute(
        path: RouteNames.progressPhotoComparison,
        name: 'photo-comparison',
        builder: (context, state) => _devLabel('photo-comparison', const PhotoComparisonPage()),
      ),
      GoRoute(
        path: RouteNames.progressComparison,
        name: 'progress-comparison',
        builder: (context, state) => _devLabel('progress-comparison', const ProgressComparisonPage()),
      ),
      GoRoute(
        path: RouteNames.progressReport,
        name: 'progress-report',
        builder: (context, state) => _devLabel('progress-report', const ProgressReportPage()),
      ),

      // Active workout
      GoRoute(
        path: '/workouts/active/:workoutId',
        name: 'active-workout',
        builder: (context, state) => _devLabel('active-workout', ActiveWorkoutPage(
          workoutId: state.pathParameters['workoutId'] ?? '',
          sessionId: state.uri.queryParameters['sessionId'],
        )),
      ),

      // Waiting for trainer (co-training request)
      GoRoute(
        path: '/workouts/waiting-trainer/:workoutId',
        name: 'waiting-for-trainer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _devLabel('waiting-for-trainer', WaitingForTrainerPage(
            workoutId: state.pathParameters['workoutId'] ?? '',
            workoutName: extra['workoutName'] as String? ?? 'Treino',
            assignmentId: extra['assignmentId'] as String?,
          ));
        },
      ),

      // Shared session (Co-training)
      GoRoute(
        path: '/sessions/:sessionId',
        name: 'shared-session',
        builder: (context, state) => _devLabel('shared-session', SharedSessionPage(
          sessionId: state.pathParameters['sessionId'] ?? '',
          mode: state.uri.queryParameters['mode'] == 'trainer'
              ? SessionMode.trainer
              : SessionMode.student,
        )),
      ),

      // Legal pages
      GoRoute(
        path: RouteNames.about,
        name: 'about',
        builder: (context, state) => _devLabel('about', const AboutPage()),
      ),
      GoRoute(
        path: RouteNames.privacy,
        name: 'privacy',
        builder: (context, state) => _devLabel('privacy', const PrivacyPage()),
      ),
      GoRoute(
        path: RouteNames.terms,
        name: 'terms',
        builder: (context, state) => _devLabel('terms', const TermsPage()),
      ),

      // Organization management
      GoRoute(
        path: RouteNames.createOrg,
        name: 'create-org',
        builder: (context, state) => _devLabel('create-org', const CreateOrgPage()),
      ),
      GoRoute(
        path: RouteNames.joinOrg,
        name: 'join-org',
        builder: (context, state) => _devLabel('join-org', const JoinOrgPage()),
      ),

      // Invite accept route (deep link)
      GoRoute(
        path: '/invite/:token',
        name: 'invite-accept',
        builder: (context, state) => _devLabel('invite-accept', InviteAcceptPage(
          token: state.pathParameters['token'] ?? '',
        )),
      ),

      // Role-based home pages
      GoRoute(
        path: '/trainer-home',
        name: 'trainer-home',
        builder: (context, state) => _devLabel('trainer-home', const TrainerHomePage()),
      ),
      GoRoute(
        path: '/nutritionist-home',
        name: 'nutritionist-home',
        builder: (context, state) => _devLabel('nutritionist-home', const NutritionistHomePage()),
      ),
      GoRoute(
        path: '/gym-home',
        name: 'gym-home',
        builder: (context, state) => _devLabel('gym-home', const GymHomePage()),
      ),

      // Role-specific chat routes (outside shell to avoid duplicate nav)
      GoRoute(
        path: '/trainer-chat',
        name: 'trainer-chat',
        builder: (context, state) => _devLabel('trainer-chat', const RoleChatWrapper(role: UserRole.trainer)),
      ),
      GoRoute(
        path: '/nutritionist-chat',
        name: 'nutritionist-chat',
        builder: (context, state) => _devLabel('nutritionist-chat', const RoleChatWrapper(role: UserRole.nutritionist)),
      ),

      // Trainer routes
      GoRoute(
        path: RouteNames.students,
        name: 'students',
        builder: (context, state) => _devLabel('students', const StudentsListPage()),
      ),
      GoRoute(
        path: '/students/:studentId/detail',
        name: 'student-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _devLabel('student-detail', StudentDetailPage(
            studentId: state.pathParameters['studentId'] ?? '',
            studentUserId: extra['studentUserId'] as String? ?? '',
            studentName: extra['studentName'] as String? ?? 'Aluno',
            studentEmail: extra['studentEmail'] as String?,
            avatarUrl: extra['avatarUrl'] as String?,
            isActive: extra['isActive'] as bool? ?? true,
          ));
        },
      ),
      GoRoute(
        path: RouteNames.schedule,
        name: 'schedule',
        builder: (context, state) => _devLabel('schedule', const SchedulePage()),
      ),
      GoRoute(
        path: RouteNames.mySchedule,
        name: 'my-schedule',
        builder: (context, state) => _devLabel('my-schedule', const StudentSchedulePage()),
      ),
      GoRoute(
        path: '/students/:studentId/workouts',
        name: 'student-workouts',
        builder: (context, state) => _devLabel('student-workouts', StudentWorkoutsPage(
          studentId: state.pathParameters['studentId'] ?? '',
          studentName: state.uri.queryParameters['name'],
        )),
      ),
      // Trainer viewing workout (outside shell to avoid duplicate nav)
      GoRoute(
        path: '/trainer/workouts/:workoutId',
        name: 'trainer-workout-detail',
        builder: (context, state) => _devLabel('trainer-workout-detail', WorkoutDetailPage(
          workoutId: state.pathParameters['workoutId'] ?? '',
        )),
      ),
      GoRoute(
        path: '/students/:studentId/plan-history',
        name: 'student-plan-history',
        builder: (context, state) => _devLabel('student-plan-history', StudentPlanHistoryPage(
          studentId: state.pathParameters['studentId'] ?? '',
          studentName: state.uri.queryParameters['name'],
        )),
      ),
      GoRoute(
        path: '/students/:studentId/progress',
        name: 'student-progress',
        builder: (context, state) => _devLabel('student-progress', TrainerStudentProgressPage(
          studentId: state.pathParameters['studentId'] ?? '',
          studentName: state.uri.queryParameters['name'],
        )),
      ),
      GoRoute(
        path: RouteNames.trainerPlans,
        name: 'trainer-plans',
        builder: (context, state) => _devLabel('trainer-plans', const TrainerPlansPage()),
      ),

      // Nutritionist routes
      GoRoute(
        path: RouteNames.patients,
        name: 'patients',
        builder: (context, state) => _devLabel('patients', const PatientsListPage()),
      ),
      GoRoute(
        path: RouteNames.dietPlans,
        name: 'diet-plans',
        builder: (context, state) => _devLabel('diet-plans', const DietPlansListPage()),
      ),
      GoRoute(
        path: '/patients/:patientId/diet-plan',
        name: 'patient-diet-plan',
        builder: (context, state) => _devLabel('patient-diet-plan', PatientDietPlanPage(
          patientId: state.pathParameters['patientId'] ?? '',
          patientName: state.uri.queryParameters['name'] ?? 'Paciente',
        )),
      ),

      // Gym management routes
      GoRoute(
        path: RouteNames.staff,
        name: 'staff',
        builder: (context, state) => _devLabel('staff', const StaffManagementPage()),
      ),
      GoRoute(
        path: RouteNames.members,
        name: 'members',
        builder: (context, state) => _devLabel('members', const MembersListPage()),
      ),
      GoRoute(
        path: '/gym-settings',
        name: 'gym-settings',
        builder: (context, state) => _devLabel('gym-settings', const GymSettingsPage()),
      ),
      GoRoute(
        path: '/gym-reports',
        name: 'gym-reports',
        builder: (context, state) => _devLabel('gym-reports', const GymReportsPage()),
      ),

      // Nutrition sub-routes
      GoRoute(
        path: '/nutrition/search',
        name: 'food-search',
        builder: (context, state) => _devLabel('food-search', const FoodSearchPage()),
      ),
      GoRoute(
        path: '/nutrition/barcode',
        name: 'barcode-scanner',
        builder: (context, state) => _devLabel('barcode-scanner', const BarcodeScannerPage()),
      ),
      GoRoute(
        path: '/nutrition/recent',
        name: 'recent-meals',
        builder: (context, state) => _devLabel('recent-meals', const RecentMealsPage()),
      ),
      GoRoute(
        path: '/nutrition/ai-suggestion',
        name: 'ai-suggestion',
        builder: (context, state) => _devLabel('ai-suggestion', const AISuggestionPage()),
      ),
      GoRoute(
        path: RouteNames.dietPlanBuilder,
        name: 'diet-plan-builder',
        builder: (context, state) => _devLabel('diet-plan-builder', DietPlanBuilderPage(
          planId: state.uri.queryParameters['planId'],
        )),
      ),
      GoRoute(
        path: RouteNames.mealLog,
        name: 'meal-log',
        builder: (context, state) => _devLabel('meal-log', const MealLogPage()),
      ),
      GoRoute(
        path: RouteNames.nutritionSummary,
        name: 'nutrition-summary',
        builder: (context, state) => _devLabel('nutrition-summary', const NutritionSummaryPage()),
      ),
      GoRoute(
        path: RouteNames.patientDetail,
        name: 'patient-detail',
        builder: (context, state) => _devLabel('patient-detail', PatientDetailPage(
          patientId: state.pathParameters['patientId'] ?? '',
        )),
      ),

      // Nutrition builder route
      GoRoute(
        path: '/nutrition/builder',
        name: 'nutrition-builder',
        builder: (context, state) => _devLabel('nutrition-builder', NutritionBuilderPage(
          planId: state.uri.queryParameters['planId'],
          studentId: state.uri.queryParameters['studentId'],
        )),
      ),

      // Smart check-in route
      GoRoute(
        path: '/checkin/smart',
        name: 'smart-checkin',
        builder: (context, state) => _devLabel('smart-checkin', const SmartCheckinPage()),
      ),

      // Trainers management route
      GoRoute(
        path: '/trainers-management',
        name: 'trainers-management',
        builder: (context, state) => _devLabel('trainers-management', const TrainersManagementPage()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Temporary placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
