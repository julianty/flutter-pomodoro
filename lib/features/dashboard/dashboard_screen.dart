import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/features/categories/category_picker.dart';
import 'package:flutter_pomodoro/features/categories/category_pie_chart.dart';
import 'package:flutter_pomodoro/services/firestore_service.dart';
import 'package:flutter_pomodoro/shared/section_card.dart';
import 'package:flutter_pomodoro/models/session_doc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Sign in to start saving and viewing data!'));
    } else {
      return StreamBuilder(
        stream: FirestoreService().watchSessions(user.uid),
        builder: (context, sessionDocsSnapshot) {
          if (sessionDocsSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!sessionDocsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<SessionDoc> sessionDocs = sessionDocsSnapshot.data!;
          // Compute total time logged
          final totalTime = sessionDocs.fold(
            0,
            (total, doc) => total + doc.duration,
          );

          // Compute # of sessions
          final totalSessions = sessionDocs.length;

          // Compute Avg length
          final avgSessionLength = totalTime / totalSessions;

          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;
          return StreamBuilder(
            stream: FirestoreService().watchCategories(user.uid),
            builder: (context, categorySnapshot) {
              if (categorySnapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (!categorySnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              List<Category> categories = categorySnapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SectionCard.muted(
                            title: "TOTAL TIME",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: textTheme.displaySmall,
                                  '$totalTime s',
                                ),
                                Text(
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.tertiary,
                                  ),
                                  'this week',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SectionCard.muted(
                            title: "SESSIONS",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: textTheme.displaySmall,
                                  '$totalSessions',
                                ),
                                Text(
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.tertiary,
                                  ),

                                  'this week',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SectionCard.muted(
                            title: "AVG DURATION",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: textTheme.displaySmall,
                                  '${avgSessionLength.round()}',
                                ),
                                Text(
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.tertiary,
                                  ),
                                  'per session',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    CategoryPieChart(
                      sessionDocs: sessionDocs,
                      categories: categories,
                    ),

                    CategoryBreakdown(
                      sessionDocs: sessionDocs,
                      categories: categories,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }
}

class CategoryBreakdown extends StatelessWidget {
  final List<SessionDoc> sessionDocs;
  final List<Category> categories;
  const CategoryBreakdown({
    super.key,
    required this.sessionDocs,
    required this.categories,
  });

  // Break sessionDocs into categories
  List<Map<String, dynamic>> categoryRowData() {
    // Get a set of unique categories in sessionDocs
    Map<String, Map<String, dynamic>> initialValue = {};
    Map<String, Map<String, dynamic>> uniqueCategories = sessionDocs.fold(
      initialValue,
      (prev, sessionDoc) {
        // Check if it exists in the map
        final id = sessionDoc.categoryId;
        if (id == null) return prev;
        if (prev[id] == null) {
          // create record
          Category? cat = categories.where((cat) => cat.id == id).firstOrNull;
          Color? color = cat?.color ?? Colors.grey;
          String? label = cat?.label ?? 'Uncategorized';
          Duration duration = Duration(seconds: sessionDoc.duration);
          prev[id] = {
            'color': color,
            'label': label,
            'duration': duration,
            'count': 1,
          };
        } else {
          prev[id] = {
            ...prev[id]!,
            'count': prev[id]!['count'] + 1,
            'duration':
                prev[id]!['duration'] + Duration(seconds: sessionDoc.duration),
          };
        }

        return prev;
      },
    );

    return uniqueCategories.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'BY CATEGORY',
      child: Column(
        children: [
          for (var data in categoryRowData())
            CategoryRow(
              color: data['color'],
              categoryLabel: data['label'],
              totalDuration: data['duration'],
              entryCount: data['count'],
            ),
        ],
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final Color color;
  final String categoryLabel;
  final Duration totalDuration;
  final int entryCount;

  const CategoryRow({
    super.key,
    required this.color,
    required this.categoryLabel,
    required this.totalDuration,
    required this.entryCount,
  });

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.toString()}m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // color dot
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
        // Formatted label
        Text(categoryLabel),
        // spacer
        Spacer(),
        // formatted duration
        Text(_formatDuration(totalDuration)),
        // count string: e.g. 3x
      ],
    );
  }
}
