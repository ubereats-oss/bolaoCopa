class Prediction {
  final String matchId;
  final String userId;
  final int homeGoals;
  final int awayGoals;
  final DateTime savedAt;
  const Prediction({
    required this.matchId,
    required this.userId,
    required this.homeGoals,
    required this.awayGoals,
    required this.savedAt,
  });
  factory Prediction.fromFirestore(String matchId, Map<String, dynamic> data) {
    return Prediction(
      matchId: matchId,
      userId: data['user_id'] ?? '',
      homeGoals: data['home_goals'] ?? 0,
      awayGoals: data['away_goals'] ?? 0,
      savedAt: (data['saved_at'] as dynamic).toDate(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'home_goals': homeGoals,
      'away_goals': awayGoals,
      'saved_at': savedAt,
    };
  }
}
