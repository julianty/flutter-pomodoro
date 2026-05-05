import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/completed_session.dart';
import 'package:flutter_pomodoro/section_card.dart';

class TimerHistory extends StatelessWidget {
  final List<CompletedSession> sessionList;
  const TimerHistory({super.key, required this.sessionList});

  @override
  Widget build(BuildContext context) {
    if (sessionList.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'TODAY\'S SESSIONS',
      child: Column(
        spacing: 8,
        children: [
          for (var session in sessionList) _SessionRow(session: session),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final CompletedSession session;
  const _SessionRow({required this.session});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          session.category?.icon ?? Icons.timer_outlined,
          size: 16,
          color: colors.onSurfaceVariant,
        ),
        SizedBox(width: 8),
        Text(
          session.category?.label ?? 'No category',
          style: textTheme.bodyMedium,
        ),
        Spacer(),
        Text(
          '${session.timerDuration.inMinutes}m',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(width: 12),
        Text(
          _formatTime(session.startedAt),
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
