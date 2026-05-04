import 'package:flutter/material.dart';

// class UserGreeting extends StatelessWidget {
//   final User? user;
//   const UserGreeting({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     if (user != null) {
//       return Center(
//         child: Column(
//           children: [Text('Hello, ${user!.displayName ?? "User"}')],
//         ),
//       );
//     } else {
//       return Center(child: Text('Hello!, sign in to get started.'));
//     }
//   }
// }

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Sign in to start saving and viewing data!'));
  }
}
