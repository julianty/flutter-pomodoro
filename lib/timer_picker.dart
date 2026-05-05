import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/category_picker.dart';
import 'package:flutter_pomodoro/section_card.dart';
import 'package:flutter_pomodoro/timer_ui.dart';

const defaultDurations = [1, 15, 30, 45, 60];

class TimerPicker extends StatelessWidget {
  final int selectedDuration;
  final Function(int) onChanged;
  final Category? selectedCategory;
  const TimerPicker({
    super.key,
    required this.selectedDuration,
    required this.onChanged,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'SESSION LENGTH',
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 5,
            crossAxisSpacing: 8.0,
            childAspectRatio: 2,
            shrinkWrap: true,
            children: [
              for (var dur in defaultDurations)
                DurationCard(
                  duration: dur,
                  active: selectedDuration == dur,
                  onTap: onChanged,
                ),
            ],
          ),
          SizedBox(height: 24),
          TimerPreview(
            selectedCategory: selectedCategory,
            selectedDuration: selectedDuration,
          ),
        ],
      ),
    );
  }
}

class DurationCard extends StatelessWidget {
  final bool active;
  final int duration; //duration in minutes
  final void Function(int) onTap;
  const DurationCard({
    super.key,
    required this.duration,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onTap(duration),
      child: Container(
        decoration: BoxDecoration(
          border: active
              ? null
              : Border.all(color: colors.onSurface, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color: active ? colors.primaryContainer : colors.surface,
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${duration}m'),
          ),
        ),
      ),
    );
  }
}

class TimerPreview extends StatelessWidget {
  final int selectedDuration; //in minutes
  final Category? selectedCategory;
  const TimerPreview({
    super.key,
    required this.selectedDuration,
    this.selectedCategory,
  });

  String categoryString(String? categoryLabel) {
    if (categoryLabel != null) {
      return categoryLabel;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimerProgressIndicator.preview(
            progress: 1,
            color:
                selectedCategory?.color ??
                Theme.of(context).colorScheme.onSurface,
            duration: Duration(minutes: selectedDuration),
          ),
          SizedBox(width: 16),
          Column(
            children: [
              Text(categoryString(selectedCategory?.label)),
              Text('${Duration(minutes: selectedDuration).inMinutes}m session'),
            ],
          ),
        ],
      ),
    );
  }
}
