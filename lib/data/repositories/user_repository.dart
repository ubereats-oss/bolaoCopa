import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<List<AppUser>> fetchAllUsers() async {
    final snapshot = await _db
        .collection('users')
        .orderBy('total_points', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Email não é exposto no ranking
      return AppUser(
        id: doc.id,
        name: data['name'] ?? '',
        email: '',
        isAdmin: data['is_admin'] ?? false,
        totalPoints: data['total_points'] ?? 0,
      );
    }).toList();
  }
  Future<void> updatePoints(String userId, int points) async {
    await _db.collection('users').doc(userId).update({
      'total_points': points,
    });
  }
}
