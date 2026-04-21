class AppUser {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final int totalPoints;
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.totalPoints,
  });
  factory AppUser.fromFirestore(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isAdmin: data['is_admin'] ?? false,
      totalPoints: data['total_points'] ?? 0,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'is_admin': isAdmin,
      'total_points': totalPoints,
    };
  }
}
