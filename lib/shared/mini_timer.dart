import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/services/timer_controller.dart';

class MiniTimer extends StatelessWidget {
  final TimerController controller;
  const MiniTimer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return (ValueListenableBuilder(
      valueListenable: controller.notifier,
      builder: (context, val, child) {
        return Text('$val');
      },
    ));
  }
}
