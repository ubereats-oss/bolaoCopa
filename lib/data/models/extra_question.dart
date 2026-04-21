enum ExtraQuestionType { team, player }

class ExtraQuestion {
  final String id;
  final String question;
  final ExtraQuestionType type;
  final int order;
  final String? positionFilter;

  const ExtraQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.order,
    this.positionFilter,
  });

  factory ExtraQuestion.fromFirestore(String id, Map<String, dynamic> data) {
    return ExtraQuestion(
      id: id,
      question: data['question'] ?? '',
      type: data['type'] == 'team'
          ? ExtraQuestionType.team
          : ExtraQuestionType.player,
      order: data['order'] ?? 0,
      positionFilter: data['position_filter'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'type': type == ExtraQuestionType.team ? 'team' : 'player',
      'order': order,
      if (positionFilter != null) 'position_filter': positionFilter,
    };
  }
}
