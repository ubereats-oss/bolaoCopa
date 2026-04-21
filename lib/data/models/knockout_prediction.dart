class KnockoutPrediction {
  final String slotId; // matchId do confronto (ex: 'r32_01')
  final String userId;
  final int homeGoals;
  final int awayGoals;
  final DateTime savedAt;

  const KnockoutPrediction({
    required this.slotId,
    required this.userId,
    required this.homeGoals,
    required this.awayGoals,
    required this.savedAt,
  });

  factory KnockoutPrediction.fromFirestore(
      String slotId, Map<String, dynamic> data) {
    return KnockoutPrediction(
      slotId: slotId,
      userId: data['user_id'] ?? '',
      homeGoals: data['home_goals'] ?? 0,
      awayGoals: data['away_goals'] ?? 0,
      savedAt: data['saved_at'] != null
          ? (data['saved_at'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user_id': userId,
        'home_goals': homeGoals,
        'away_goals': awayGoals,
        'saved_at': savedAt,
      };
}
