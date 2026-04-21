import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Usuário autenticado atual
  User? get currentUser => _auth.currentUser;
  // Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // Login com e-mail e senha
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Registro com e-mail e senha
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await _saveUserToFirestore(
      uid: credential.user!.uid,
      name: name,
      email: email.trim(),
    );
    return credential;
  }

  // Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    // Cria o perfil no Firestore apenas se for o primeiro login
    final doc =
        await _db.collection('users').doc(userCredential.user!.uid).get();
    if (!doc.exists) {
      await _saveUserToFirestore(
        uid: userCredential.user!.uid,
        name: googleUser.displayName ?? 'Usuário',
        email: googleUser.email,
      );
    }
    return userCredential;
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Envia e-mail de recuperação de senha
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Busca o perfil do usuário no Firestore
  Future<AppUser?> fetchAppUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(uid, doc.data()!);
  }

  // Salva usuário novo no Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'is_admin': false,
      'total_points': 0,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
