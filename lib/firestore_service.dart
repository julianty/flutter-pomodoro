import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/category_picker.dart';
import 'package:flutter_pomodoro/completed_session.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentReference<Object?>> saveSession(
    String uid,
    CompletedSession session,
  ) async {
    // Prepare collection ref
    CollectionReference userCompletedSessions = firestore.collection(
      'users/$uid/sessions',
    );

    // Unpack data from completedSession
    Map<String, dynamic> data = {
      'startedAt': session.startedAt,
      'completedAt': session.completedAt,
      'duration': session.timerDuration.inSeconds,
      'categoryLabel': session.category?.label ?? 'none',
    };
    // Upload to firestore
    return userCompletedSessions.add(data);
  }

  Map<String, dynamic> _unpackCategory(Category category) {
    Map<String, dynamic> data = {
      'color': category.color.toARGB32(),
      'icon': category.icon.codePoint,
      'label': category.label,
    };
    return data;
  }

  Future<DocumentReference<Object?>> saveCategory(
    String uid,
    Category category,
  ) async {
    CollectionReference userCategories = firestore.collection(
      'users/$uid/categories',
    );

    // Unpack data from category
    Map<String, dynamic> data = _unpackCategory(category);

    return userCategories.add(data);
  }

  Future<void> updateCategory(String uid, Category category) async {
    CollectionReference userCategories = firestore.collection(
      'users/$uid/categories',
    );

    // Unpack data from category
    Map<String, dynamic> data = _unpackCategory(category);

    return userCategories.doc(category.id).update({...data});
  }

  Stream<List<Category>> watchCategories(String uid) {
    CollectionReference userCategories = firestore.collection(
      'users/$uid/categories',
    );

    Stream<QuerySnapshot<Object?>> stream = userCategories.snapshots();
    Stream<List<Category>> categoryStream = stream.map(
      (snapshot) => [
        for (var doc in snapshot.docs)
          Category(
            id: doc.id,
            icon: IconData(doc['icon'], fontFamily: 'MaterialIcons'),
            label: doc['label'],
            color: Color(doc['color']),
          ),
      ],
    );
    return categoryStream;
  }

  Future<void> deleteCategory(String uid, Category category) async {
    CollectionReference categories = firestore.collection(
      'users/$uid/categories',
    );
    categories
        .doc(category.id)
        .delete()
        .catchError((error) => print("Failed to delete category"));
  }
}
