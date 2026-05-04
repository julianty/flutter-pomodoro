import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/countdown_screen.dart';
import 'package:flutter_pomodoro/timer_controller.dart';
import 'package:flutter_pomodoro/timer_history.dart';
import 'category_picker.dart';
import 'timer_picker.dart';

class TimerScreen extends StatefulWidget {
  final TimerController controller;
  const TimerScreen({super.key, required this.controller});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Category? _selectedCategory;

  int _selectedDuration = 30;

  void changeSelectedCategory(Category cat) {
    setState(() {
      _selectedCategory = cat;
    });
  }

  void changeTimerDuration(int dur) {
    setState(() {
      _selectedDuration = dur;
    });
  }

  void handleStart(BuildContext context) {
    widget.controller.start(_selectedDuration * 60, _selectedCategory);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CountdownScreen(
            timerController: widget.controller,
            categoryName: _selectedCategory?.label,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 480
              ? 480
              : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Adjust the value as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              CategoryPicker(
                categories: defaultCategories,
                selectedCategory: _selectedCategory,
                onChanged: changeSelectedCategory,
              ),
              TimerPicker(
                selectedDuration: _selectedDuration,
                selectedCategoryLabel: _selectedCategory?.label,
                onChanged: changeTimerDuration,
              ),

              // TODO: Add a history reader here
              ValueListenableBuilder(
                valueListenable: widget.controller.completedSessions,
                builder: (context, currentSessionList, child) {
                  return TimerHistory(sessionList: currentSessionList);
                },
              ),
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  onPressed: () {
                    handleStart(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_right,
                          color: colorScheme.onPrimary,
                          size: 32,
                        ),
                        Text(
                          'Start session',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
