import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/features/categories/category_picker.dart';
import 'package:flutter_pomodoro/services/timer_controller.dart';
import 'package:flutter_pomodoro/features/timer/timer_ui.dart';

class CountdownScreen extends StatelessWidget {
  final TimerController timerController;
  final Category? category;

  const CountdownScreen({
    super.key,
    required this.timerController,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: timerController.notifier,
              builder: (BuildContext context, value, child) {
                Duration remainingDuration = Duration(
                  seconds: timerController.notifier.value,
                );
                return TimerDisplay(
                  categoryLabel: category?.label,
                  color: category?.color,
                  displayDuration: remainingDuration,
                  totalDuration: timerController.initialDuration,
                );
              },
            ),
            SizedBox(height: 24),
            ValueListenableBuilder(
              valueListenable: timerController.timerState,
              builder: (context, value, child) {
                return switch (value) {
                  TimerState.running => PauseButton(
                    onPressed: () => timerController.pause(),
                  ),
                  TimerState.paused => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayButton(onPressed: () => timerController.resume()),
                      ResetButton(
                        onPressed: () {
                          timerController.reset();
                        },
                      ),
                      StopButton(
                        onPressed: () {
                          timerController.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  TimerState.completed => StopButton(
                    onPressed: () {
                      timerController.stop();
                      Navigator.pop(context);
                    },
                  ),
                  TimerState.idle => const SizedBox.shrink(),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  final void Function() onPressed;
  const ResetButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(onPressed: onPressed, icon: Icon(Icons.loop));
  }
}

class PauseButton extends StatelessWidget {
  final void Function() onPressed;
  const PauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(onPressed: onPressed, icon: Icon(Icons.pause));
  }
}

class PlayButton extends StatelessWidget {
  final void Function() onPressed;
  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // return ElevatedButton(onPressed: onPressed, child: Text('play'));
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(Icons.play_arrow),
    );
  }
}

class StopButton extends StatelessWidget {
  final void Function() onPressed;
  const StopButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // return ElevatedButton(onPressed: onPressed, child: Text('stop'));
    return IconButton.filledTonal(onPressed: onPressed, icon: Icon(Icons.stop));
  }
}

class TimerDisplay extends StatelessWidget {
  final Color? color;
  final Duration displayDuration;
  final Duration totalDuration;
  final String? categoryLabel;
  const TimerDisplay({
    super.key,
    this.color,
    required this.displayDuration,
    required this.totalDuration,
    this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;
    double progress = displayDuration.inSeconds / totalDuration.inSeconds;
    return TimerProgressIndicator(
      progress: progress,
      color: resolvedColor,
      duration: displayDuration,
      categoryLabel: categoryLabel,
    );
  }
}
