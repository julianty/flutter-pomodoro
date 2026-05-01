import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithGoogle() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  return await FirebaseAuth.instance.signInWithPopup(googleProvider);
}

Future<void> signOut() async {
  return await FirebaseAuth.instance.signOut();
}
