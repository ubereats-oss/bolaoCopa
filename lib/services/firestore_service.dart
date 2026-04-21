import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/cup.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Cache em memória — evita leituras repetidas ao Firestore
  static Cup? _cachedCup;
  Future<Cup?> fetchActiveCup({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCup != null) return _cachedCup;
    final query = await _db
        .collection('cups')
        .where('active', isEqualTo: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    _cachedCup = Cup.fromFirestore(doc.id, doc.data());
    return _cachedCup;
  }
  static void clearCache() {
    _cachedCup = null;
  }
}
