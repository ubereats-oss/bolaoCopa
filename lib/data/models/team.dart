class Team {
  final String id;       // ex: "BRA"
  final String name;     // ex: "Brasil"
  final String flagAsset; // ex: "assets/flags/bra.png"
  const Team({
    required this.id,
    required this.name,
    required this.flagAsset,
  });
  factory Team.fromFirestore(String id, Map<String, dynamic> data) {
    return Team(
      id: id,
      name: data['name'] ?? '',
      flagAsset: 'assets/flags/${id.toLowerCase()}.png',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
