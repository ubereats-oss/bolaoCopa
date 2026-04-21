import 'package:flutter/material.dart';
import '../../../core/constants/bracket_data.dart';
import '../../../data/models/team.dart';
import '../../matches/bracket_engine.dart';
import '../widgets/score_control.dart';
import '../widgets/team_block.dart';

class BracketMatchCard extends StatelessWidget {
  final ResolvedMatch resolved;
  final Map<String, Team> teams;
  final bool locked;
  final List<int> palpite;
  final bool isSaving;
  final void Function(int side) onIncrement;
  final void Function(int side) onDecrement;
  final VoidCallback onSave;

  const BracketMatchCard({
    super.key,
    required this.resolved,
    required this.teams,
    required this.locked,
    required this.palpite,
    required this.isSaving,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final home =
        resolved.homeTeamId != null ? teams[resolved.homeTeamId] : null;
    final away =
        resolved.awayTeamId != null ? teams[resolved.awayTeamId] : null;
    final phaseLabel = BracketData.phaseLabels[resolved.def.phase] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildCard(home, away, phaseLabel),
      ),
    );
  }

  Widget _buildCard(Team? home, Team? away, String phaseLabel) {
    final homeLabel = home?.name ?? resolved.homeSlotLabel;
    final awayLabel = away?.name ?? resolved.awaySlotLabel;

    return Column(
      children: [
        Text(phaseLabel,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TeamBlock(
                team: home,
                fallbackLabel: homeLabel,
              ),
            ),
            ScoreControl(
              homeGoals: palpite[0],
              awayGoals: palpite[1],
              locked: locked || !resolved.canPredict,
              onIncrementHome: () => onIncrement(0),
              onDecrementHome: () => onDecrement(0),
              onIncrementAway: () => onIncrement(1),
              onDecrementAway: () => onDecrement(1),
            ),
            Expanded(
              child: TeamBlock(
                team: away,
                alignRight: true,
                fallbackLabel: awayLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (!locked && resolved.canPredict)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isSaving ? null : onSave,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A6B3C),
                side: const BorderSide(color: Color(0xFF1A6B3C)),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF1A6B3C)),
                    )
                  : const Text('Salvar palpite'),
            ),
          )
        else if (!resolved.canPredict && !locked)
          const Text(
            'Complete os palpites da fase anterior',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
      ],
    );
  }
}
