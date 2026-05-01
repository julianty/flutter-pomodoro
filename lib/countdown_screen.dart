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
            ElevatedButton(
              onPressed: () {
                timerController.reset();
                Navigator.pop(context);
              },
              child: Text('reset'),
            ),
          ],
        ),
      ),
    );
  }
}
