import 'package:flutter/material.dart';

class TimerProgressIndicator extends StatelessWidget {
  final double progress; //value from 0.0-1.0
  final Color color;
  final Duration duration; //time in ms

  const TimerProgressIndicator({
    super.key,
    required this.progress,
    required this.color,
    required this.duration,
  });

  String formattedDuration(Duration duration) {
    int seconds = duration.inSeconds;
    int minutes = (seconds / 60).toInt();
    seconds -= minutes * 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(value: progress, color: color),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(formattedDuration(duration))],
          ),
        ),
      ],
    );
  }
}
