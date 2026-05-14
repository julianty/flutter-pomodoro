import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_pomodoro/features/categories/category_picker.dart';
import 'package:flutter_pomodoro/features/categories/category_pie_chart.dart';
import 'package:flutter_pomodoro/features/timer/timer_history.dart';
import 'package:flutter_pomodoro/models/completed_session.dart';
import 'package:flutter_pomodoro/services/firestore_service.dart';
import 'package:flutter_pomodoro/shared/section_card.dart';
import 'package:flutter_pomodoro/models/session_doc.dart';

enum _TimeWindow {
  today(0),
  sevenDays(7),
  thirtyDays(30);

  final int days;
  const _TimeWindow(this.days);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _TimeWindow timeWindow = _TimeWindow.sevenDays;

  DateTime computeStartDate(_TimeWindow timeWindow) {
    return DateTime.now().subtract(Duration(days: timeWindow.days));
  }

  void handleTimeWindowSelect(_TimeWindow window) {
    setState(() {
      timeWindow = window;
    });
  }

  String computeTimeString(int seconds) {
    Duration totalDuration = Duration(seconds: seconds);
    if (totalDuration.compareTo(Duration(minutes: 1)) < 0) {
      // total duration is less than a minute
      return '$seconds s';
    }
    if (totalDuration.compareTo(Duration(hours: 1)) < 0) {
      // total duration is less than 1 hour
      int minutes = totalDuration.inMinutes;
      int leftoverSeconds = totalDuration.inSeconds - minutes * 60;
      return '$minutes m $leftoverSeconds s';
    }
    // Total duration is greater than 1 hour
    int hours = totalDuration.inHours;
    int leftoverMinutes = totalDuration.inMinutes - hours * 60;
    return '$hours h $leftoverMinutes m';
  }

  String timeWindowString(_TimeWindow window) {
    switch (window) {
      case _TimeWindow.today:
        return 'today';
      case _TimeWindow.sevenDays:
        return 'this week';
      case _TimeWindow.thirtyDays:
        return 'last 30 days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        User? user = userSnapshot.data;
        if (user == null) {
          return Center(
            child: Text('Sign in to start saving and viewing data!'),
          );
        }
        return StreamBuilder(
          stream: FirestoreService().watchSessionsAfterDate(
            user.uid,
            computeStartDate(timeWindow),
          ),
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
            final avgSessionLength = totalSessions > 0
                ? totalTime / totalSessions
                : 0;

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
                      // Time window selectors
                      Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                handleTimeWindowSelect(_TimeWindow.today),
                            child: Text('Today'),
                          ),
                          TextButton(
                            onPressed: () =>
                                handleTimeWindowSelect(_TimeWindow.sevenDays),
                            child: Text('7 days'),
                          ),
                          TextButton(
                            onPressed: () =>
                                handleTimeWindowSelect(_TimeWindow.thirtyDays),
                            child: Text('30 days'),
                          ),
                        ],
                      ),
                      // Top row of cards
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
                                    computeTimeString(totalTime),
                                  ),
                                  Text(
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.tertiary,
                                    ),
                                    timeWindowString(timeWindow),
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
                                    timeWindowString(timeWindow),
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
                                    computeTimeString(avgSessionLength.round()),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CategoryBreakdown(
                              sessionDocs: sessionDocs,
                              categories: categories,
                            ),
                          ),
                          // Builder for timer history
                          Expanded(
                            child: StreamBuilder(
                              stream: FirestoreService().watchTodaysSessions(
                                user.uid,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text(
                                    'An error occured while fetching',
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Text('No sessions yet today');
                                }
                                final List<SessionDoc> sessionDocs =
                                    snapshot.data!;
                                final List<CompletedSession> sessionList = [
                                  for (var doc in sessionDocs)
                                    CompletedSession(
                                      category: categories.firstWhereOrNull(
                                        (cat) => cat.id == doc.categoryId,
                                      ),
                                      timerDuration: Duration(
                                        seconds: doc.duration,
                                      ),
                                      startedAt: doc.startedAt,
                                    ),
                                ];
                                final truncatedSessionList =
                                    sessionList.length > 5
                                    ? sessionList
                                          .sublist(sessionList.length - 5)
                                          .reversed
                                          .toList()
                                    : sessionList.reversed.toList();
                                return SingleChildScrollView(
                                  child: TimerHistory(
                                    sessionList: truncatedSessionList,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
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
