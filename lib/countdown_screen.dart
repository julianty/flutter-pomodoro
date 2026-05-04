import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/timer_controller.dart';

class CountdownScreen extends StatelessWidget {
  final TimerController timerController;
  final String? categoryName;

  const CountdownScreen({
    super.key,
    required this.timerController,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(categoryName ?? 'no category'),
            ValueListenableBuilder(
              valueListenable: timerController.notifier,
              builder: (BuildContext context, value, child) {
                String minutes = (value ~/ 60).toString().padLeft(2, '0');
                String seconds = (value % 60).toString().padLeft(2, '0');
                return Text('$minutes:$seconds');
              },
            ),
            ValueListenableBuilder(
              valueListenable: timerController.timerState,
              builder: (context, value, child) {
                return switch (value) {
                  TimerState.running => PauseButton(
                    onPressed: () => timerController.pause(),
                  ),
                  TimerState.paused => Row(
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
    return ElevatedButton(onPressed: onPressed, child: Text('reset'));
  }
}

class PauseButton extends StatelessWidget {
  final void Function() onPressed;
  const PauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text('pause'));
  }
}

class PlayButton extends StatelessWidget {
  final void Function() onPressed;
  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text('play'));
  }
}

class StopButton extends StatelessWidget {
  final void Function() onPressed;
  const StopButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text('stop'));
  }
}
