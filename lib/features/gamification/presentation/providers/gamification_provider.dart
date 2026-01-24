import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/cache.dart';
import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/gamification_service.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/leaderboard.dart';

// Service provider
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

// User points state
class UserPointsState {
  final int points;
  final bool isLoading;
  final String? error;

  const UserPointsState({
    this.points = 0,
    this.isLoading = false,
    this.error,
  });

  UserPointsState copyWith({
    int? points,
    bool? isLoading,
    String? error,
  }) {
    return UserPointsState(
      points: points ?? this.points,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User points notifier
class UserPointsNotifier extends StateNotifier<UserPointsState> {
  final GamificationService _service;

  UserPointsNotifier(this._service) : super(const UserPointsState()) {
    loadPoints();
  }

  Future<void> loadPoints() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getMyPoints();
      final points = data['total_points'] as int? ?? 0;
      state = state.copyWith(points: points, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar pontos');
    }
  }

  void refresh() => loadPoints();
}

final userPointsNotifierProvider = StateNotifierProvider<UserPointsNotifier, UserPointsState>((ref) {
  final service = ref.watch(gamificationServiceProvider);
  return UserPointsNotifier(service);
});

// Simple points provider for backward compatibility
final userPointsProvider = Provider<int>((ref) {
  return ref.watch(userPointsNotifierProvider).points;
});

// User level provider
final userLevelProvider = Provider<UserLevel>((ref) {
  final points = ref.watch(userPointsProvider);
  return _getUserLevel(points);
});

UserLevel _getUserLevel(int points) {
  if (points >= 50001) {
    return UserLevel(
      name: 'Elite',
      icon: '👑',
      minPoints: 50001,
      maxPoints: 100000,
      currentPoints: points,
    );
  } else if (points >= 15001) {
    return UserLevel(
      name: 'Diamante',
      icon: '💎',
      minPoints: 15001,
      maxPoints: 50000,
      currentPoints: points,
    );
  } else if (points >= 5001) {
    return UserLevel(
      name: 'Ouro',
      icon: '🥇',
      minPoints: 5001,
      maxPoints: 15000,
      currentPoints: points,
    );
  } else if (points >= 1001) {
    return UserLevel(
      name: 'Prata',
      icon: '🥈',
      minPoints: 1001,
      maxPoints: 5000,
      currentPoints: points,
    );
  } else {
    return UserLevel(
      name: 'Bronze',
      icon: '🥉',
      minPoints: 0,
      maxPoints: 1000,
      currentPoints: points,
    );
  }
}

// Leaderboard period provider
final leaderboardPeriodProvider = StateProvider<LeaderboardPeriod>((ref) => LeaderboardPeriod.monthly);

// Leaderboard state
class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.entries = const [],
    this.currentUserEntry,
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? currentUserEntry,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      currentUserEntry: currentUserEntry ?? this.currentUserEntry,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Leaderboard notifier
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final GamificationService _service;
  final Ref _ref;

  LeaderboardNotifier(this._service, this._ref) : super(const LeaderboardState()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final period = _ref.read(leaderboardPeriodProvider);
      final periodStr = _periodToString(period);

      final results = await Future.wait([
        _service.getLeaderboard(period: periodStr),
        _service.getMyLeaderboardPosition(period: periodStr),
      ]);

      final leaderboardData = results[0] as List<Map<String, dynamic>>;
      final myPosition = results[1] as Map<String, dynamic>?;

      final entries = leaderboardData.map((e) => LeaderboardEntry(
        rank: e['rank'] as int,
        memberId: e['user_id'] as String,
        memberName: e['user_name'] as String? ?? 'Usuário',
        memberAvatarUrl: e['avatar_url'] as String?,
        points: e['points'] as int? ?? 0,
        checkIns: e['check_ins'] as int? ?? 0,
        workoutsCompleted: e['workouts_completed'] as int? ?? 0,
        rankChange: e['rank_change'] as int?,
        levelIcon: e['level_icon'] as String?,
        levelName: e['level_name'] as String?,
      )).toList();

      LeaderboardEntry? currentUser;
      if (myPosition != null) {
        currentUser = LeaderboardEntry(
          rank: myPosition['rank'] as int,
          memberId: myPosition['user_id'] as String,
          memberName: 'Você',
          memberAvatarUrl: myPosition['avatar_url'] as String?,
          points: myPosition['points'] as int? ?? 0,
          checkIns: myPosition['check_ins'] as int? ?? 0,
          workoutsCompleted: myPosition['workouts_completed'] as int? ?? 0,
          rankChange: myPosition['rank_change'] as int?,
          levelIcon: myPosition['level_icon'] as String?,
          levelName: myPosition['level_name'] as String?,
        );
      }

      state = state.copyWith(
        entries: entries,
        currentUserEntry: currentUser,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar ranking');
    }
  }

  String _periodToString(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.weekly:
        return 'weekly';
      case LeaderboardPeriod.monthly:
        return 'monthly';
      case LeaderboardPeriod.allTime:
        return 'all_time';
    }
  }

  void refresh() => loadLeaderboard();
}

final leaderboardNotifierProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final service = ref.watch(gamificationServiceProvider);
  ref.watch(leaderboardPeriodProvider);
  return LeaderboardNotifier(service, ref);
});

// Leaderboard provider for backward compatibility
final leaderboardProvider = Provider<Leaderboard>((ref) {
  final state = ref.watch(leaderboardNotifierProvider);
  final period = ref.watch(leaderboardPeriodProvider);
  return Leaderboard(
    period: period,
    entries: state.entries,
    currentUserEntry: state.currentUserEntry,
    updatedAt: DateTime.now(),
  );
});

// Achievements state
class AchievementsState {
  final List<Achievement> all;
  final List<Achievement> mine;
  final bool isLoading;
  final String? error;

  const AchievementsState({
    this.all = const [],
    this.mine = const [],
    this.isLoading = false,
    this.error,
  });

  AchievementsState copyWith({
    List<Achievement>? all,
    List<Achievement>? mine,
    bool? isLoading,
    String? error,
  }) {
    return AchievementsState(
      all: all ?? this.all,
      mine: mine ?? this.mine,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Achievements notifier
class AchievementsNotifier extends StateNotifier<AchievementsState> {
  final GamificationService _service;

  AchievementsNotifier(this._service) : super(const AchievementsState()) {
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getAllAchievements(),
        _service.getMyAchievements(),
      ]);

      final allData = results[0] as List<Map<String, dynamic>>;
      final mineData = results[1] as List<Map<String, dynamic>>;

      final mineIds = mineData.map((e) => e['achievement_id'] as String).toSet();

      final all = allData.map((e) {
        final id = e['id'] as String;
        final isUnlocked = mineIds.contains(id);
        final myData = mineData.firstWhere(
          (m) => m['achievement_id'] == id,
          orElse: () => <String, dynamic>{},
        );

        return Achievement(
          id: id,
          name: e['name'] as String,
          description: e['description'] as String,
          icon: e['icon'] as String? ?? '🏆',
          category: _parseCategory(e['category'] as String?),
          rarity: _parseRarity(e['rarity'] as String?),
          pointsReward: e['points_reward'] as int? ?? 0,
          unlockedAt: isUnlocked ? DateTime.tryParse(myData['unlocked_at'] as String? ?? '') : null,
          progress: e['progress'] as double?,
          currentValue: e['current_value'] as int?,
          targetValue: e['target_value'] as int?,
        );
      }).toList();

      final mine = all.where((a) => a.unlockedAt != null).toList();

      state = state.copyWith(
        all: all,
        mine: mine,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar conquistas');
    }
  }

  AchievementCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'consistency':
        return AchievementCategory.consistency;
      case 'progress':
        return AchievementCategory.progress;
      case 'social':
        return AchievementCategory.social;
      case 'milestone':
        return AchievementCategory.milestone;
      case 'special':
        return AchievementCategory.special;
      default:
        return AchievementCategory.milestone;
    }
  }

  AchievementRarity _parseRarity(String? rarity) {
    switch (rarity?.toLowerCase()) {
      case 'common':
        return AchievementRarity.common;
      case 'rare':
        return AchievementRarity.rare;
      case 'epic':
        return AchievementRarity.epic;
      case 'legendary':
        return AchievementRarity.legendary;
      default:
        return AchievementRarity.common;
    }
  }

  void refresh() => loadAchievements();
}

final achievementsNotifierProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  final service = ref.watch(gamificationServiceProvider);
  return AchievementsNotifier(service);
});

// Achievements provider for backward compatibility
final achievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(achievementsNotifierProvider).all;
});

// Unlocked achievements provider
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final all = ref.watch(achievementsProvider);
  return all.where((a) => a.unlockedAt != null).toList();
});

// Locked achievements provider
final lockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final all = ref.watch(achievementsProvider);
  return all.where((a) => a.unlockedAt == null).toList();
});

// Points history state
class PointsHistoryState {
  final List<PointsTransaction> transactions;
  final bool isLoading;
  final String? error;

  const PointsHistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  PointsHistoryState copyWith({
    List<PointsTransaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return PointsHistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Points history notifier
class PointsHistoryNotifier extends StateNotifier<PointsHistoryState> {
  final GamificationService _service;

  PointsHistoryNotifier(this._service) : super(const PointsHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getPointsHistory();
      final transactions = data.map((e) => PointsTransaction(
        id: e['id'] as String,
        description: e['description'] as String,
        points: e['points'] as int,
        timestamp: DateTime.parse(e['created_at'] as String),
        source: e['source'] as String,
        relatedId: e['related_id'] as String?,
      )).toList();

      state = state.copyWith(transactions: transactions, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar histórico');
    }
  }

  void refresh() => loadHistory();
}

final pointsHistoryNotifierProvider = StateNotifierProvider<PointsHistoryNotifier, PointsHistoryState>((ref) {
  final service = ref.watch(gamificationServiceProvider);
  return PointsHistoryNotifier(service);
});

// Points history provider for backward compatibility
final pointsHistoryProvider = Provider<List<PointsTransaction>>((ref) {
  return ref.watch(pointsHistoryNotifierProvider).transactions;
});

// Stats data
class GamificationStatsData {
  final int totalCheckIns;
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;

  const GamificationStatsData({
    this.totalCheckIns = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWorkouts = 0,
  });
}

// Stats state
class GamificationStatsState implements CachedState<GamificationStatsData> {
  @override
  final GamificationStatsData? data;
  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final CacheMetadata cache;

  const GamificationStatsState({
    this.data,
    this.isLoading = false,
    this.error,
    this.cache = const CacheMetadata(),
  });

  // CachedState implementation
  @override
  bool get hasData => data != null;

  @override
  bool isStale(CacheConfig config) => cache.isStale(config);

  @override
  bool get isBackgroundRefresh => cache.isRefreshing && hasData;

  // Convenience getters
  int get totalCheckIns => data?.totalCheckIns ?? 0;
  int get currentStreak => data?.currentStreak ?? 0;
  int get longestStreak => data?.longestStreak ?? 0;
  int get totalWorkouts => data?.totalWorkouts ?? 0;

  GamificationStatsState copyWith({
    GamificationStatsData? data,
    bool? isLoading,
    String? error,
    CacheMetadata? cache,
  }) {
    return GamificationStatsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cache: cache ?? this.cache,
    );
  }
}

// Stats notifier
class GamificationStatsNotifier
    extends CachedStateNotifier<GamificationStatsState> {
  final GamificationService _service;

  GamificationStatsNotifier({
    required Ref ref,
    required GamificationService service,
  })  : _service = service,
        super(
          const GamificationStatsState(),
          config: CacheConfigs.gamificationStats, // 30 min TTL
          ref: ref,
        );

  /// Events that should trigger a refresh of this provider
  @override
  Set<CacheEventType> get invalidationEvents => {
        CacheEventType.workoutCompleted,
        CacheEventType.checkInCompleted,
        CacheEventType.achievementUnlocked,
        CacheEventType.pointsEarned,
        CacheEventType.appResumed,
      };

  @override
  Future<void> fetchData() async {
    try {
      final results = await Future.wait([
        _service.getGamificationStats(),
        _service.getStreak(),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      final streak = results[1] as Map<String, dynamic>;

      final data = GamificationStatsData(
        totalCheckIns: stats['total_checkins'] as int? ?? 0,
        totalWorkouts: stats['total_workouts'] as int? ?? 0,
        currentStreak: streak['current_streak'] as int? ?? 0,
        longestStreak: streak['longest_streak'] as int? ?? 0,
      );

      onFetchSuccess(data);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas');
    }
  }

  @override
  GamificationStatsState updateStateWithData(
    dynamic data,
    CacheMetadata newCache,
  ) {
    return state.copyWith(
      data: data as GamificationStatsData,
      isLoading: false,
      error: null,
      cache: newCache,
    );
  }

  @override
  GamificationStatsState updateStateForLoading(
    bool isLoading,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: isLoading, cache: cache);
  }

  @override
  GamificationStatsState updateStateForError(
    String error,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: false, error: error, cache: cache);
  }

  // Keep old method name for backwards compatibility
  Future<void> loadStats() => loadData(forceRefresh: true);
}

final gamificationStatsNotifierProvider =
    StateNotifierProvider<GamificationStatsNotifier, GamificationStatsState>(
        (ref) {
  final service = ref.watch(gamificationServiceProvider);
  return GamificationStatsNotifier(ref: ref, service: service);
});

// Stats providers for backward compatibility
final totalCheckInsProvider = Provider<int>((ref) {
  return ref.watch(gamificationStatsNotifierProvider).totalCheckIns;
});

final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(gamificationStatsNotifierProvider).currentStreak;
});

final longestStreakProvider = Provider<int>((ref) {
  return ref.watch(gamificationStatsNotifierProvider).longestStreak;
});

final totalWorkoutsProvider = Provider<int>((ref) {
  return ref.watch(gamificationStatsNotifierProvider).totalWorkouts;
});
