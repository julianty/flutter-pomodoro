import 'package:cloud_firestore/cloud_firestore.dart';

class SessionDoc {
  final String? categoryId;
  final String? categoryLabel;
  final int duration; //in seconds
  final DateTime startedAt;
  final DateTime completedAt;

  SessionDoc({
    this.categoryId,
    this.categoryLabel,
    required this.duration,
    required this.startedAt,
    required this.completedAt,
  });

  factory SessionDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return SessionDoc(
      categoryId: data['categoryId'] as String?,
      categoryLabel: data['categoryLabel'] as String?,
      duration: data['duration'],
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toFirestore(
    SessionDoc sessionDoc,
    SetOptions? options,
  ) {
    Map<String, dynamic> doc = {
      'categoryId': sessionDoc.categoryId,
      'categoryLabel': sessionDoc.categoryLabel,
      'duration': sessionDoc.duration,
      'startedAt': sessionDoc.startedAt,
      'completedAt': sessionDoc.completedAt,
    };
    return doc;
  }
}
