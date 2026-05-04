import 'category_picker.dart';

class CompletedSession {
  Category? category;
  final Duration timerDuration;
  final DateTime startedAt; // Needs to be read in
  // Computed
  final DateTime completedAt = DateTime.now(); //Date.now()
  CompletedSession({
    this.category,
    required this.timerDuration,
    required this.startedAt,
  });
}
