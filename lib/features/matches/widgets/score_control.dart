import 'package:flutter/material.dart';
class ScoreControl extends StatelessWidget {
  final int homeGoals;
  final int awayGoals;
  final bool locked;
  final VoidCallback onIncrementHome;
  final VoidCallback onDecrementHome;
  final VoidCallback onIncrementAway;
  final VoidCallback onDecrementAway;
  const ScoreControl({
    super.key,
    required this.homeGoals,
    required this.awayGoals,
    required this.locked,
    required this.onIncrementHome,
    required this.onDecrementHome,
    required this.onIncrementAway,
    required this.onDecrementAway,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GoalStepper(
          value: homeGoals,
          locked: locked,
          onIncrement: onIncrementHome,
          onDecrement: onDecrementHome,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '×',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: locked ? Colors.grey : Colors.black87,
            ),
          ),
        ),
        GoalStepper(
          value: awayGoals,
          locked: locked,
          onIncrement: onIncrementAway,
          onDecrement: onDecrementAway,
        ),
      ],
    );
  }
}
class GoalStepper extends StatelessWidget {
  final int value;
  final bool locked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const GoalStepper({
    super.key,
    required this.value,
    required this.locked,
    required this.onIncrement,
    required this.onDecrement,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton.filled(
            onPressed: locked ? null : onIncrement,
            icon: const Icon(Icons.add, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: locked
                  ? Colors.grey.withValues(alpha: 0.2)
                  : const Color(0xFF1A6B3C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: locked ? Colors.grey : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton.filled(
            onPressed: locked ? null : onDecrement,
            icon: const Icon(Icons.remove, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: locked
                  ? Colors.grey.withValues(alpha: 0.2)
                  : const Color(0xFF1A6B3C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
