import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/category_form.dart';
import 'package:flutter_pomodoro/category_picker.dart';
import 'package:flutter_pomodoro/firestore_service.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please sign in to add and modify categories'));
    } else {
      return StreamBuilder(
        stream: FirestoreService().watchCategories(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // render loading
            return Center(child: Text('loading..'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occured'));
          }

          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => CategoryForm(),
                );
              },
              child: Icon(Icons.add),
            ),
            body: Column(
              children: [
                for (var category in snapshot.data ?? [])
                  CategoryCard(category: category, onTap: (cat) {}),
              ],
            ),
          );
        },
      );
    }
  }
}
