import 'package:cloud_firestore/cloud_firestore.dart';
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
}
