import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/completed_session.dart';

class TimerHistory extends StatelessWidget {
  final List<CompletedSession> sessionList;
  const TimerHistory({super.key, required this.sessionList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var session in sessionList)
          Row(
            children: [
              Text(session.category?.label ?? 'No category'),
              Text('${session.timerDuration.inMinutes} min'),
            ],
          ),
      ],
    );
  }
}
