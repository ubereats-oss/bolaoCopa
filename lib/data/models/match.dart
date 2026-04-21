class Match {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final DateTime matchTime;
  final String phase;
  final String? groupId;
  final int? officialHomeGoals;
  final int? officialAwayGoals;
  final bool finished;
  const Match({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.matchTime,
    required this.phase,
    this.groupId,
    this.officialHomeGoals,
    this.officialAwayGoals,
    required this.finished,
  });
  factory Match.fromFirestore(String id, Map<String, dynamic> data) {
    return Match(
      id: id,
      homeTeamId: data['home_team_id'] ?? '',
      awayTeamId: data['away_team_id'] ?? '',
      matchTime: (data['match_time'] as dynamic).toDate(),
      phase: data['phase'] ?? 'group',
      groupId: data['group_id'],
      officialHomeGoals: data['official_home_goals'],
      officialAwayGoals: data['official_away_goals'],
      finished: data['finished'] ?? false,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'match_time': matchTime,
      'phase': phase,
      'group_id': groupId,
      'official_home_goals': officialHomeGoals,
      'official_away_goals': officialAwayGoals,
      'finished': finished,
    };
  }
}
