class Player {
  final String id;
  final String name;
  final String teamId;
  final String position;
  final int number;
  final bool reserva;

  const Player({
    required this.id,
    required this.name,
    required this.teamId,
    required this.position,
    this.number = 0,
    this.reserva = false,
  });

  factory Player.fromFirestore(String id, Map<String, dynamic> data) {
    return Player(
      id: id,
      name: data['name'] ?? '',
      teamId: data['team_id'] ?? '',
      position: data['position'] ?? '',
      number: data['number'] ?? 0,
      reserva: data['reserva'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'team_id': teamId,
      'position': position,
      'number': number,
      'reserva': reserva,
    };
  }
}
