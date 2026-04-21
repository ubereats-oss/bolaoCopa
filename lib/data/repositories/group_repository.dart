import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bolao_group.dart';
import '../models/prediction.dart';
import '../models/extra_prediction.dart';

class GroupRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _groups => _db.collection('bolao_groups');

  // ── Gera código de convite único (6 chars alfanumérico) ──────────────────
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    var seed = rnd;
    for (var i = 0; i < 6; i++) {
      result += chars[seed % chars.length];
      seed = (seed ~/ chars.length) + i * 7;
    }
    return result;
  }

  // ── Criar grupo ──────────────────────────────────────────────────────────
  Future<BolaoGroup> createGroup({
    required String name,
    required String cupId,
    required String adminUid,
  }) async {
    final inviteCode = _generateCode();
    final now = DateTime.now();

    final ref = await _groups.add({
      'name': name.trim(),
      'admin_uid': adminUid,
      'invite_code': inviteCode,
      'cup_id': cupId,
      'created_at': Timestamp.fromDate(now),
    });

    // Admin vira membro com role 'admin'
    await ref.collection('members').doc(adminUid).set({
      'role': 'admin',
      'points': 0,
      'joined_at': Timestamp.fromDate(now),
    });

    // Registra groupId no array do usuário para lookup sem índice composto
    await _db.collection('users').doc(adminUid).set({
      'group_ids': FieldValue.arrayUnion([ref.id]),
    }, SetOptions(merge: true));

    final doc = await ref.get();
    return BolaoGroup.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }

  // ── Entrar por código de convite ─────────────────────────────────────────
  Future<BolaoGroup?> joinByCode(String code, String userId) async {
    final query = await _groups
        .where('invite_code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final groupId = doc.id;

    // Verifica se já é membro
    final memberDoc =
        await _groups.doc(groupId).collection('members').doc(userId).get();
    if (memberDoc.exists) {
      return BolaoGroup.fromFirestore(
          doc.id, doc.data() as Map<String, dynamic>);
    }

    final now = DateTime.now();
    await _groups.doc(groupId).collection('members').doc(userId).set({
      'role': 'member',
      'points': 0,
      'joined_at': Timestamp.fromDate(now),
    });

    await _db.collection('users').doc(userId).set({
      'group_ids': FieldValue.arrayUnion([groupId]),
    }, SetOptions(merge: true));

    return BolaoGroup.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }

  // ── Buscar grupos do usuário ─────────────────────────────────────────────
  Future<List<BolaoGroup>> fetchUserGroups(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final data = userDoc.data() ?? {};
    final ids = List<String>.from(data['group_ids'] ?? []);
    if (ids.isEmpty) return [];

    final docs = await Future.wait(ids.map((id) => _groups.doc(id).get()));
    return docs
        .where((d) => d.exists)
        .map((d) =>
            BolaoGroup.fromFirestore(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  // ── Buscar membros de um grupo ordenados por pontos ──────────────────────
  Future<List<BolaoMember>> fetchMembers(String groupId) async {
    final snap = await _groups
        .doc(groupId)
        .collection('members')
        .orderBy('points', descending: true)
        .get();
    return snap.docs
        .map((d) => BolaoMember.fromFirestore(d.id, d.data()))
        .toList();
  }

  // ── Palpite de jogo por grupo ────────────────────────────────────────────
  CollectionReference _predictions(String groupId, String userId) => _groups
      .doc(groupId)
      .collection('members')
      .doc(userId)
      .collection('predictions');

  Future<Prediction?> fetchPrediction(
      String groupId, String userId, String matchId) async {
    final doc = await _predictions(groupId, userId).doc(matchId).get();
    if (!doc.exists) return null;
    return Prediction.fromFirestore(matchId, doc.data() as Map<String, dynamic>);
  }

  Future<Map<String, Prediction>> fetchAllPredictions(
      String groupId, String userId) async {
    final snap = await _predictions(groupId, userId).get();
    return {
      for (final d in snap.docs)
        d.id: Prediction.fromFirestore(d.id, d.data() as Map<String, dynamic>)
    };
  }

  Future<void> savePrediction(String groupId, Prediction p) async {
    await _predictions(groupId, p.userId).doc(p.matchId).set(p.toFirestore());
  }

  // ── Palpite extra por grupo ──────────────────────────────────────────────
  CollectionReference _extraPredictions(String groupId, String userId) =>
      _groups
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .collection('extra_predictions');

  Future<Map<String, ExtraPrediction>> fetchAllExtraPredictions(
      String groupId, String userId) async {
    final snap = await _extraPredictions(groupId, userId).get();
    return {
      for (final d in snap.docs)
        d.id: ExtraPrediction.fromFirestore(
            d.id, d.data() as Map<String, dynamic>)
    };
  }

  Future<void> saveExtraPrediction(
      String groupId, ExtraPrediction p) async {
    await _extraPredictions(groupId, p.userId)
        .doc(p.questionId)
        .set(p.toFirestore());
  }

  // ── Atualizar pontos de um membro ────────────────────────────────────────
  Future<void> updateMemberPoints(
      String groupId, String userId, int points) async {
    await _groups
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .update({'points': points});
  }

  // ── Verificar se usuário é membro ────────────────────────────────────────
  Future<BolaoMember?> fetchMember(String groupId, String userId) async {
    final doc =
        await _groups.doc(groupId).collection('members').doc(userId).get();
    if (!doc.exists) return null;
    return BolaoMember.fromFirestore(doc.id, doc.data()!);
  }

  // ── Sair do grupo ────────────────────────────────────────────────────────
  Future<void> leaveGroup(String groupId, String userId) async {
    await _groups.doc(groupId).collection('members').doc(userId).delete();
    await _db.collection('users').doc(userId).update({
      'group_ids': FieldValue.arrayRemove([groupId]),
    });
  }

  // ── Deletar grupo (apenas admin) ─────────────────────────────────────────
  Future<void> deleteGroup(String groupId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Remove groupId de todos os membros
    final members =
        await _groups.doc(groupId).collection('members').get();
    for (final m in members.docs) {
      await _db.collection('users').doc(m.id).update({
        'group_ids': FieldValue.arrayRemove([groupId]),
      });
    }
    await _groups.doc(groupId).delete();
  }
}
