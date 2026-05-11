import 'package:flutter/material.dart';

class TimerProgressIndicator extends StatelessWidget {
  final double progress; //value from 0.0-1.0
  final Color color;
  final Duration duration; //time in ms
  final double width;
  final double height;
  final String? categoryLabel;

  const TimerProgressIndicator({
    super.key,
    required this.progress,
    required this.color,
    required this.duration,
    this.categoryLabel,
    this.width = 240,
    this.height = 240,
  });

  const TimerProgressIndicator.preview({
    super.key,
    required this.progress,
    required this.color,
    required this.duration,
    this.categoryLabel,
  }) : width = 60,
       height = 60;

  String formattedDuration(Duration duration) {
    int seconds = duration.inSeconds;
    int minutes = (seconds / 60).toInt();
    seconds -= minutes * 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = width >= 240
        ? textTheme.headlineMedium!
        : textTheme.bodyMedium!;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: CircularProgressIndicator(
            value: progress,
            color: color,
            strokeWidth: width >= 240 ? 24.0 : 3.0,
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (categoryLabel != null) Text(categoryLabel!),
              Text(style: textStyle, formattedDuration(duration)),
            ],
          ),
        ),
      ],
    );
  }
}
