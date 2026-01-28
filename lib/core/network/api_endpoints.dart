/// API Endpoints constants for MyFit app
/// All endpoint paths are relative to the base URL

class ApiEndpoints {
  ApiEndpoints._();

  // ==================== Auth ====================
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authGoogle = '/auth/google';
  static const String authApple = '/auth/apple';
  static const String authSendVerification = '/auth/send-verification';
  static const String authVerifyCode = '/auth/verify-code';
  static const String authResendVerification = '/auth/resend-verification';

  // ==================== Users ====================
  static const String userProfile = '/users/profile';
  static const String userAvatar = '/users/avatar';
  static const String userSettings = '/users/settings';
  static const String userPassword = '/users/password';
  static const String userSearch = '/users/search';

  // ==================== Organizations ====================
  static const String organizations = '/organizations/';
  static const String organizationsAutonomous = '/organizations/autonomous';
  static String organization(String id) => '/organizations/$id';
  static String organizationMembers(String id) => '/organizations/$id/members';
  static String organizationMember(String orgId, String userId) =>
      '/organizations/$orgId/members/$userId';
  static String reactivateMember(String orgId, String membershipId) =>
      '/organizations/$orgId/members/$membershipId/reactivate';
  static String leaveOrganization(String orgId) => '/organizations/$orgId/leave';
  static String organizationInvite(String id) => '/organizations/$id/invite';
  static String organizationInvites(String id) => '/organizations/$id/invites';
  static String cancelInvite(String orgId, String inviteId) =>
      '/organizations/$orgId/invites/$inviteId';
  static String resendInvite(String orgId, String inviteId) =>
      '/organizations/$orgId/invites/$inviteId/resend';
  static const String acceptInvite = '/organizations/accept-invite';
  static const String acceptInviteByCode = '/organizations/accept-invite-by-code';
  static String invitePreview(String token) => '/organizations/invite/preview/$token';
  static String invitePreviewByCode(String shortCode) => '/organizations/invite/code/$shortCode';

  // ==================== Workouts ====================
  static const String workouts = '/workouts';
  static String workout(String id) => '/workouts/$id';
  static String workoutDuplicate(String id) => '/workouts/$id/duplicate';
  static String workoutExercises(String id) => '/workouts/$id/exercises';
  static String workoutExercise(String workoutId, String exerciseId) =>
      '/workouts/$workoutId/exercises/$exerciseId';

  // ==================== Exercises ====================
  static const String exercises = '/workouts/exercises';
  static String exercise(String id) => '/workouts/exercises/$id';
  static const String exercisesSuggest = '/workouts/exercises/suggest';

  // ==================== Workout Assignments ====================
  static const String workoutAssignments = '/workouts/assignments';
  static String workoutAssignment(String id) => '/workouts/assignments/$id';

  // ==================== Workout Sessions ====================
  static const String workoutSessions = '/workouts/sessions';
  static String workoutSession(String id) => '/workouts/sessions/$id';
  static String workoutSessionComplete(String id) =>
      '/workouts/sessions/$id/complete';
  static String workoutSessionSets(String id) => '/workouts/sessions/$id/sets';

  // ==================== Training Plans ====================
  static const String plans = '/workouts/plans';
  static const String plansCatalog = '/workouts/plans/catalog';
  static const String plansGenerateAI = '/workouts/plans/generate-ai';
  static String plan(String id) => '/workouts/plans/$id';
  static String planDuplicate(String id) => '/workouts/plans/$id/duplicate';
  static String planWorkouts(String id) => '/workouts/plans/$id/workouts';
  static String planWorkout(String planId, String workoutId) =>
      '/workouts/plans/$planId/workouts/$workoutId';
  static const String planAssignments = '/workouts/plans/assignments';
  static String planAssignment(String id) => '/workouts/plans/assignments/$id';
  static String planAssignmentAcknowledge(String id) =>
      '/workouts/plans/assignments/$id/acknowledge';
  static String planAssignmentRespond(String id) =>
      '/workouts/plans/assignments/$id/respond';

  // ==================== Exercise Feedback ====================
  static String exerciseFeedback(String sessionId, String workoutExerciseId) =>
      '/workouts/sessions/$sessionId/exercises/$workoutExerciseId/feedback';
  static String sessionFeedbacks(String sessionId) =>
      '/workouts/sessions/$sessionId/feedbacks';
  static const String trainerExerciseFeedbacks = '/workouts/trainer/exercise-feedbacks';
  static String respondToFeedback(String feedbackId) =>
      '/workouts/feedbacks/$feedbackId/respond';

  // ==================== Prescription Notes ====================
  static const String prescriptionNotes = '/workouts/notes';
  static String prescriptionNote(String id) => '/workouts/notes/$id';
  static String prescriptionNoteRead(String id) => '/workouts/notes/$id/read';

  // ==================== Nutrition - Foods ====================
  static const String foods = '/nutrition/foods';
  static String food(String id) => '/nutrition/foods/$id';
  static String foodBarcode(String barcode) =>
      '/nutrition/foods/barcode/$barcode';
  static const String foodFavorites = '/nutrition/foods/favorites';
  static String foodFavorite(String id) => '/nutrition/foods/$id/favorite';

  // ==================== Nutrition - Diet Plans ====================
  static const String dietPlans = '/nutrition/diet-plans';
  static String dietPlan(String id) => '/nutrition/diet-plans/$id';

  // ==================== Nutrition - Assignments ====================
  static const String dietAssignments = '/nutrition/assignments';
  static String dietAssignment(String id) => '/nutrition/assignments/$id';

  // ==================== Nutrition - Meal Logs ====================
  static const String mealLogs = '/nutrition/meals';
  static String mealLog(String id) => '/nutrition/meals/$id';
  static const String nutritionDailySummary = '/nutrition/summary/daily';
  static const String nutritionWeeklySummary = '/nutrition/summary/weekly';

  // ==================== Nutrition - Patient Notes ====================
  static String patientNotes(String patientId) =>
      '/nutrition/patients/$patientId/notes';

  // ==================== Nutrition - Patient Diet ====================
  static String patientDietPlan(String patientId) =>
      '/nutrition/patients/$patientId/diet-plan';
  static String patientDietHistory(String patientId) =>
      '/nutrition/patients/$patientId/diet-history';

  // ==================== Progress - Weight ====================
  static const String weightLogs = '/progress/weight';
  static String weightLog(String id) => '/progress/weight/$id';
  static const String weightLatest = '/progress/weight/latest';

  // ==================== Progress - Measurements ====================
  static const String measurementLogs = '/progress/measurements';
  static String measurementLog(String id) => '/progress/measurements/$id';
  static const String measurementLatest = '/progress/measurements/latest';

  // ==================== Progress - Photos ====================
  static const String progressPhotos = '/progress/photos';
  static String progressPhoto(String id) => '/progress/photos/$id';

  // ==================== Progress - Goals ====================
  static const String weightGoal = '/progress/goal';

  // ==================== Progress - Stats ====================
  static const String progressStats = '/progress/stats';

  // ==================== Progress - Personal Records ====================
  static const String personalRecords = '/progress/personal-records';
  static String personalRecord(String id) => '/progress/personal-records/$id';
  static String exercisePersonalRecords(String exerciseId) =>
      '/progress/personal-records/exercise/$exerciseId';
  static const String personalRecordsRecent = '/progress/personal-records/recent';

  // ==================== Progress - Milestones ====================
  static const String milestones = '/progress/milestones';
  static String milestoneDetail(String id) => '/progress/milestones/$id';
  static String milestoneProgress(String id) => '/progress/milestones/$id/progress';
  static String milestoneComplete(String id) => '/progress/milestones/$id/complete';

  // ==================== Progress - AI Insights ====================
  static const String aiInsights = '/progress/insights';
  static String dismissInsight(String id) => '/progress/insights/$id/dismiss';
  static const String generateInsights = '/progress/insights/generate';

  // ==================== Check-ins - Gyms ====================
  static const String gyms = '/checkins/gyms';
  static String gym(String id) => '/checkins/gyms/$id';

  // ==================== Check-ins ====================
  static const String checkins = '/checkins';
  static const String checkinActive = '/checkins/active';
  static const String checkinByCode = '/checkins/code';
  static const String checkinByLocation = '/checkins/location';
  static const String checkout = '/checkins/checkout';
  static const String checkinStats = '/checkins/stats';

  // ==================== Check-in Codes ====================
  static const String checkinCodes = '/checkins/codes';
  static String checkinCode(String code) => '/checkins/codes/$code';

  // ==================== Check-in Requests ====================
  static const String checkinRequests = '/checkins/requests';
  static String checkinRequestRespond(String id) =>
      '/checkins/requests/$id/respond';

  // ==================== Gamification - Points ====================
  static const String points = '/gamification/points';
  static const String pointsHistory = '/gamification/points/history';
  static const String pointsStreak = '/gamification/points/streak';

  // ==================== Gamification - Achievements ====================
  static const String achievements = '/gamification/achievements';
  static const String myAchievements = '/gamification/achievements/mine';
  static const String awardAchievement = '/gamification/achievements/award';

  // ==================== Gamification - Leaderboard ====================
  static const String leaderboard = '/gamification/leaderboard';
  static const String myLeaderboardPosition = '/gamification/leaderboard/me';
  static const String refreshLeaderboard = '/gamification/leaderboard/refresh';

  // ==================== Gamification - Stats ====================
  static const String gamificationStats = '/gamification/stats';

  // ==================== Trainers ====================
  static const String trainerStudents = '/trainers/students';
  static String trainerStudent(String id) => '/trainers/students/$id';
  static String trainerStudentStats(String id) => '/trainers/students/$id/stats';
  static String trainerStudentWorkouts(String id) => '/trainers/students/$id/workouts';
  static String trainerStudentProgress(String id) => '/trainers/students/$id/progress';
  static String trainerStudentReinvite(String userId) => '/trainers/students/$userId/reinvite';
  static const String trainerInviteCode = '/trainers/my-invite-code';

  // ==================== Notifications ====================
  static const String notifications = '/notifications/notifications';
  static String notification(String id) => '/notifications/notifications/$id';
  static String notificationRead(String id) => '/notifications/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/notifications/read-all';
  static const String notificationsUnreadCount = '/notifications/notifications/unread-count';

  // ==================== Push Notifications / Devices ====================
  static const String registerDevice = '/notifications/notifications/devices';
  static String unregisterDevice(String token) => '/notifications/notifications/devices/$token';

  // ==================== Schedule/Appointments ====================
  static const String schedule = '/schedule';
  static String scheduleDay(String date) => '/schedule/day/$date';
  static String scheduleWeek(String date) => '/schedule/week/$date';
  static const String scheduleAppointments = '/schedule/appointments';
  static String scheduleAppointment(String id) => '/schedule/appointments/$id';
  static String scheduleAppointmentCancel(String id) => '/schedule/appointments/$id/cancel';
  static String scheduleAppointmentConfirm(String id) => '/schedule/appointments/$id/confirm';
  static String scheduleAppointmentReschedule(String id) => '/schedule/appointments/$id/reschedule';
  static const String myAppointments = '/schedule/appointments/mine';

  // ==================== Chat ====================
  static const String chatConversations = '/chat/conversations';
  static String chatConversation(String id) => '/chat/conversations/$id';
  static String chatMessages(String conversationId) => '/chat/conversations/$conversationId/messages';
  static String chatSendMessage(String conversationId) => '/chat/conversations/$conversationId/messages';

  // ==================== Health ====================
  static const String health = '/health';

  // ==================== Memberships ====================
  static const String userMemberships = '/users/me/memberships';
  static const String userPendingInvites = '/users/me/pending-invites';

  // ==================== Student Dashboard ====================
  static const String studentDashboard = '/users/me/dashboard';

  // ==================== Billing ====================
  static const String billingPayments = '/billing/payments';
  static String billingPayment(String id) => '/billing/payments/$id';
  static const String billingSummary = '/billing/summary';

  // ==================== Marketplace ====================
  static const String marketplaceTemplates = '/marketplace/templates';
  static const String marketplaceFeatured = '/marketplace/templates/featured';
  static String marketplaceTemplate(String id) => '/marketplace/templates/$id';
  static String marketplaceTemplatePreview(String id) => '/marketplace/templates/$id/preview';
  static String marketplaceCheckout(String templateId) => '/marketplace/templates/$templateId/checkout';
  static const String marketplaceMyTemplates = '/marketplace/my-templates';
  static String marketplacePurchaseStatus(String purchaseId) => '/marketplace/purchases/$purchaseId/status';
  static const String marketplaceMyPurchases = '/marketplace/my-purchases';
  static String marketplacePurchaseReview(String purchaseId) => '/marketplace/purchases/$purchaseId/review';
  static String marketplaceTemplateReviews(String templateId) => '/marketplace/templates/$templateId/reviews';
  static const String marketplaceCategories = '/marketplace/categories';
  static const String marketplaceCreatorDashboard = '/marketplace/creator/dashboard';
  static const String marketplaceCreatorEarnings = '/marketplace/creator/earnings';
  static const String marketplaceCreatorPayouts = '/marketplace/creator/payouts';
  static String organizationTemplates(String orgId) => '/marketplace/organization/$orgId/templates';
}
