class Cup {
  final String id;
  final String name;
  final int year;
  final bool active;
  final DateTime startsAt;
  const Cup({
    required this.id,
    required this.name,
    required this.year,
    required this.active,
    required this.startsAt,
  });
  bool get isLocked => DateTime.now().isAfter(startsAt);
  factory Cup.fromFirestore(String id, Map<String, dynamic> data) {
    return Cup(
      id: id,
      name: data['name'] ?? '',
      year: data['year'] ?? 0,
      active: data['active'] ?? false,
      startsAt: (data['starts_at'] as dynamic).toDate(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'year': year,
      'active': active,
      'starts_at': startsAt,
    };
  }
}
