import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/features/categories/category_picker.dart';
import 'package:flutter_pomodoro/shared/section_card.dart';
import 'package:flutter_pomodoro/models/session_doc.dart';

class CategoryPieChart extends StatelessWidget {
  final List<SessionDoc> sessionDocs;
  final List<Category> categories;

  const CategoryPieChart({
    super.key,
    required this.sessionDocs,
    required this.categories,
  });

  List<Map<String, dynamic>> _buildData() {
    final Map<String, Map<String, dynamic>> accumulated = sessionDocs.fold({}, (
      prev,
      sessionDoc,
    ) {
      final id = sessionDoc.categoryId;
      if (id == null) return prev;
      if (prev[id] == null) {
        Category? cat = categories.where((c) => c.id == id).firstOrNull;
        prev[id] = {
          'color': cat?.color ?? Colors.grey,
          'label':
              (cat?.label ?? sessionDoc.categoryLabel)?.replaceAll(
                'none',
                'Uncategorized',
              ) ??
              'Uncategorized',
          'duration': sessionDoc.duration,
        };
      } else {
        prev[id]!['duration'] = prev[id]!['duration'] + sessionDoc.duration;
      }
      return prev;
    });
    return accumulated.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildData();
    if (data.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'CATEGORY PIE CHART',
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sections: data
                        .map(
                          (d) => PieChartSectionData(
                            value: (d['duration'] as int).toDouble(),
                            color: d['color'] as Color,
                            title: '',
                            radius: 50,
                          ),
                        )
                        .toList(),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var d in data) ...[
                  Builder(
                    builder: (context) {
                      final total = data.fold<int>(
                        0,
                        (sum, d) => sum + (d['duration'] as int),
                      );
                      final pct = total > 0
                          ? ((d['duration'] as int) / total * 100).round()
                          : 0;
                      return Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: d['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${d['label']} — $pct%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
