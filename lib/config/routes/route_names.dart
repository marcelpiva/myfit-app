/// Route path constants
abstract class RouteNames {
  // Auth
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';
  static const orgSelector = '/org-selector';

  // Main tabs
  static const home = '/home';
  static const workouts = '/workouts';
  static const nutrition = '/nutrition';
  static const progress = '/progress';
  static const chat = '/chat';
  static const checkin = '/checkin';
  static const checkinHistory = '/checkin/history';
  static const qrScanner = '/checkin/qr-scanner';
  static const qrGenerator = '/checkin/qr-generator';
  static const leaderboard = '/leaderboard';
  static const billing = '/billing';
  static const coachDashboard = '/coach';

  // Workout routes
  static const workoutDetail = '/workouts/:workoutId';
  static const workoutBuilder = '/workouts/builder';
  static const planWizard = '/plans/wizard';
  static const planDetail = '/plans/:planId';
  static const activeWorkout = '/workouts/active/:sessionId';
  static const exerciseLibrary = '/workouts/exercises';

  // Nutrition routes
  static const dietPlanDetail = '/nutrition/:planId';
  static const mealBuilder = '/nutrition/builder';
  static const dailyLog = '/nutrition/log';
  static const dietPlanBuilder = '/nutrition/diet-plan/builder';
  static const mealLog = '/nutrition/meal-log';
  static const nutritionSummary = '/nutrition/summary';
  static const patientDetail = '/patients/:patientId/detail';

  // Progress routes
  static const progressPhotos = '/progress/photos';
  static const progressPhotoComparison = '/progress/photos/compare';
  static const measurements = '/progress/measurements';
  static const analytics = '/progress/analytics';
  static const weightGoal = '/progress/goal';
  static const progressStats = '/progress/stats';

  // Chat routes
  static const conversation = '/chat/:conversationId';

  // Profile & Settings
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';

  // Organization
  static const orgSwitch = '/org-switch';
  static const orgSettings = '/org-settings';

  // Payments
  static const payments = '/payments';
  static const paymentHistory = '/payments/history';

  // Marketplace
  static const marketplace = '/marketplace';
  static const marketplaceItem = '/marketplace/:id';

  // Other
  static const notifications = '/notifications';
  static const help = '/help';

  // Legal
  static const about = '/about';
  static const privacy = '/privacy';
  static const terms = '/terms';

  // Organization management
  static const createOrg = '/org/create';
  static const joinOrg = '/org/join';

  // Role-based home pages
  static const trainerHome = '/trainer-home';
  static const nutritionistHome = '/nutritionist-home';
  static const gymHome = '/gym-home';

  // Trainer routes
  static const students = '/students';
  static const schedule = '/schedule';
  static const studentWorkouts = '/students/:studentId/workouts';
  static const trainerPlans = '/trainer-plans';

  // Nutritionist routes
  static const patients = '/patients';
  static const dietPlans = '/diet-plans';
  static const appointments = '/appointments';

  // Gym management routes
  static const staff = '/staff';
  static const members = '/members';
  static const gymSettings = '/gym-settings';

  // Invite routes
  static const inviteAccept = '/invite/:token';
}
