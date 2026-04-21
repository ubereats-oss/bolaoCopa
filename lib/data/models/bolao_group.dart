import 'package:cloud_firestore/cloud_firestore.dart';

class BolaoGroup {
  final String id;
  final String name;
  final String adminUid;
  final String inviteCode;
  final String cupId;
  final DateTime createdAt;

  const BolaoGroup({
    required this.id,
    required this.name,
    required this.adminUid,
    required this.inviteCode,
    required this.cupId,
    required this.createdAt,
  });

  factory BolaoGroup.fromFirestore(String id, Map<String, dynamic> data) {
    return BolaoGroup(
      id: id,
      name: data['name'] ?? '',
      adminUid: data['admin_uid'] ?? '',
      inviteCode: data['invite_code'] ?? '',
      cupId: data['cup_id'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'admin_uid': adminUid,
        'invite_code': inviteCode,
        'cup_id': cupId,
        'created_at': Timestamp.fromDate(createdAt),
      };
}

class BolaoMember {
  final String userId;
  final String role; // 'admin' | 'member'
  final int points;
  final DateTime joinedAt;

  const BolaoMember({
    required this.userId,
    required this.role,
    required this.points,
    required this.joinedAt,
  });

  factory BolaoMember.fromFirestore(String userId, Map<String, dynamic> data) {
    return BolaoMember(
      userId: userId,
      role: data['role'] ?? 'member',
      points: data['points'] ?? 0,
      joinedAt: (data['joined_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'role': role,
        'points': points,
        'joined_at': Timestamp.fromDate(joinedAt),
      };

  bool get isAdmin => role == 'admin';
}
