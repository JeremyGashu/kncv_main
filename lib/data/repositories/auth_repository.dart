import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth auth;

  AuthRepository(this.auth);
  Future loginUser({required String email, required String password}) async {
    UserCredential user =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    if (user.user != null) {
      return user.user;
    }
    return null;
  }

  User? currentUser() {
    return auth.currentUser;
  }

  Future<bool?> logoutUser() async {
    await auth.signOut();
    return true;
  }
}
