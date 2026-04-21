import 'package:flutter/material.dart';
import '../../../data/models/team.dart';

class TeamBlock extends StatelessWidget {
  final Team? team;
  final bool alignRight;
  final String? fallbackLabel;

  const TeamBlock({
    super.key,
    required this.team,
    this.alignRight = false,
    this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            team?.flagAsset ?? '',
            width: 48,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.flag_outlined, size: 32),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          team?.name ?? fallbackLabel ?? '?',
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
