class Group {
  final String id;
  final String name;
  const Group({
    required this.id,
    required this.name,
  });
  factory Group.fromFirestore(String id, Map<String, dynamic> data) {
    return Group(
      id: id,
      name: data['name'] ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}
