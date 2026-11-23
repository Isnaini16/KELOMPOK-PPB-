
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<User?> get users => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<bool> isCurrentUserAdmin() async {
    final u = _auth.currentUser;
    if (u == null) return false;
    final snap = await _db.collection('admins').doc(u.uid)
      .get(const GetOptions(source: Source.server));
    return snap.data()?['role'] == 'admin' && snap.data()?['is_active'] == true;
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    try {
      if (!await isCurrentUserAdmin()) throw Exception('Akun ini tidak memiliki hak akses admin.');
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }
  Future<void> logout() => _auth.signOut();
  Future<void> resetPassword() async {
    final email = _auth.currentUser?.email;
    if (email == null) throw Exception('Email admin tidak ditemukan.');
    await _auth.sendPasswordResetEmail(email: email);
  }
  Future<void> updateName(String name) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Admin belum login.');
    await _db.collection('admins').doc(u.uid).update({'nama': name.trim()});
  }
}
