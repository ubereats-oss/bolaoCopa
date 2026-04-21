import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/knockout_prediction.dart';

class KnockoutPredictionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, KnockoutPrediction>> fetchAll(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('knockout_predictions')
        .get();
    return {
      for (final doc in snap.docs)
        doc.id: KnockoutPrediction.fromFirestore(doc.id, doc.data())
    };
  }

  Future<void> save(KnockoutPrediction p) async {
    await _db
        .collection('users')
        .doc(p.userId)
        .collection('knockout_predictions')
        .doc(p.slotId)
        .set(p.toFirestore());
  }
}
