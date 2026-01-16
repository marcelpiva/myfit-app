import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard.freezed.dart';
part 'leaderboard.g.dart';

enum LeaderboardPeriod {
  weekly,
  monthly,
  allTime,
}

@freezed
sealed class LeaderboardEntry with _$LeaderboardEntry {
  const LeaderboardEntry._();

  const factory LeaderboardEntry({
    required int rank,
    required String memberId,
    required String memberName,
    String? memberAvatarUrl,
    required int points,
    required int checkIns,
    required int workoutsCompleted,
    int? rankChange,
    String? levelIcon,
    String? levelName,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
}

@freezed
sealed class Leaderboard with _$Leaderboard {
  const Leaderboard._();

  const factory Leaderboard({
    required LeaderboardPeriod period,
    required List<LeaderboardEntry> entries,
    LeaderboardEntry? currentUserEntry,
    required DateTime updatedAt,
  }) = _Leaderboard;

  factory Leaderboard.fromJson(Map<String, dynamic> json) => _$LeaderboardFromJson(json);
}
