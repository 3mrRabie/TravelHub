import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get authChanges => _auth.authStateChanges();
 
  Future<User?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that email.';
        case 'wrong-password':
          throw 'Wrong password provided.';
        case 'invalid-email':
          throw 'Invalid email address.';
        default:
          throw 'Login failed. Please try again.';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

 
  User? get currentUser => _auth.currentUser;

 
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
