import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/features/categories/category_picker.dart';
import 'package:flutter_pomodoro/models/completed_session.dart';
import 'package:flutter_pomodoro/features/categories/icon_map.dart';
import 'package:flutter_pomodoro/models/session_doc.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentReference<SessionDoc>> saveSession(
    String uid,
    CompletedSession session,
  ) async {
    // Prepare collection ref
    CollectionReference<SessionDoc> userCompletedSessions = firestore
        .collection('users/$uid/sessions')
        .withConverter(
          fromFirestore: SessionDoc.fromFirestore,
          toFirestore: SessionDoc.toFirestore,
        );

    // Unpack data from completedSession
    SessionDoc data = SessionDoc(
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      duration: session.timerDuration.inSeconds,
      categoryLabel: session.category?.label ?? 'none',
      categoryId: session.category?.id ?? 'none',
    );
    // Upload to firestore
    return userCompletedSessions.add(data);
  }

  Stream<List<SessionDoc>> watchSessions(String uid) {
    // Prepare collection ref
    CollectionReference<SessionDoc> userCompletedSessions = firestore
        .collection('users/$uid/sessions')
        .withConverter<SessionDoc>(
          fromFirestore: SessionDoc.fromFirestore,
          toFirestore: SessionDoc.toFirestore,
        );
    Stream<QuerySnapshot<SessionDoc>> completedSessionsSnapshot =
        userCompletedSessions.snapshots();

    Stream<List<SessionDoc>> sessionDocStream = completedSessionsSnapshot.map(
      (snapshot) => [for (var doc in snapshot.docs) doc.data()],
    );
    return sessionDocStream;
  }

  Map<String, dynamic> _unpackCategory(Category category) {
    Map<String, dynamic> data = {
      'color': category.color.toARGB32(),
      'iconIdentifier': reverseIconMap[category.icon],
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
            icon: iconMap[doc['iconIdentifier'] ?? 'development']!,
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
        .catchError((error) => debugPrint("Failed to delete category: $error"));
  }

  Future<Category?> getCategoryData(String uid, String categoryId) async {
    DocumentReference docRef = firestore.doc(
      'users/$uid/categories/$categoryId',
    );
    DocumentSnapshot docSnapshot = await docRef.get();

    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      return null;
    }
    Category? category = Category(
      id: docSnapshot.id,
      color: Color(data['color']),
      label: data['label'],
      icon: iconMap[data['iconIdentifier']] ?? iconMap['development']!,
    );

    return category;
  }
}
