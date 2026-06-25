import 'package:firebase_auth/firebase_auth.dart';

class LoginFirebaseService {
  final FirebaseAuth _auth;

  LoginFirebaseService(this._auth);

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
