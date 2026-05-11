import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/features/timer/countdown_screen.dart';
import 'package:flutter_pomodoro/services/firestore_service.dart';
import 'package:flutter_pomodoro/services/timer_controller.dart';
import 'package:flutter_pomodoro/features/timer/timer_history.dart';
import '../categories/category_picker.dart';
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
            category: _selectedCategory,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    User? user = FirebaseAuth.instance.currentUser;
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
              if (user != null)
                StreamBuilder(
                  stream: FirestoreService().watchCategories(user.uid),
                  builder: (context, snapshot) {
                    List<Category>? categories = snapshot.data;
                    return CategoryPicker(
                      categories: categories?.isEmpty == true
                          ? defaultCategories
                          : categories ?? defaultCategories,
                      selectedCategory: _selectedCategory,
                      onChanged: changeSelectedCategory,
                    );
                  },
                ),
              if (user == null)
                CategoryPicker(
                  categories: defaultCategories,
                  selectedCategory: _selectedCategory,
                  onChanged: changeSelectedCategory,
                ),

              TimerPicker(
                selectedDuration: _selectedDuration,
                selectedCategory: _selectedCategory,
                onChanged: changeTimerDuration,
              ),

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
