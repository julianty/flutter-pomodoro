import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<UserCredential> signInWithGoogle() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  return await FirebaseAuth.instance.signInWithPopup(googleProvider);
}

Future<void> signOut() async {
  return await FirebaseAuth.instance.signOut();
}

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(user.displayName ?? "User"),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
            ],
          );
        } else {
          return TextButton(
            onPressed: signInWithGoogle,
            child: Text("Sign in with Google"),
          );
        }
      },
    );
  }
}
