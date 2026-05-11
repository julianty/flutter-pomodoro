import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool muted;
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.muted = false,
  });

  const SectionCard.muted({super.key, required this.title, required this.child})
    : muted = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bgColor = muted
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerHigh;
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              title,
            ),
            SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }
}
