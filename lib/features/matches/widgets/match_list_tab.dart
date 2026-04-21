import 'package:flutter/material.dart';
import '../../../data/models/match.dart';
import '../../../data/models/team.dart';
import '../../../data/models/cup.dart';
import 'match_card.dart';
import '../../matches/group_standings_screen.dart';

class MatchListTab extends StatelessWidget {
  final List<Match> matches;
  final Map<String, Team> teams;
  final Cup cup;
  // null = sem palpite; List<int> = palpite salvo
  final Map<String, List<int>?> palpites;
  final Map<String, bool> saving;
  final bool savingAll;
  final void Function(String matchId, int side) onIncrement;
  final void Function(String matchId, int side) onDecrement;
  final Future<void> Function(Match match) onSaveOne;
  final Future<void> Function() onSaveAll;

  const MatchListTab({
    super.key,
    required this.matches,
    required this.teams,
    required this.cup,
    required this.palpites,
    required this.saving,
    required this.savingAll,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSaveOne,
    required this.onSaveAll,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(child: Text('Nenhum jogo disponível.'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupStandingsScreen(
                    groupMatches: matches,
                    palpites: palpites,
                    teams: teams,
                  ),
                ),
              ),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Ver classificação dos grupos'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1A6B3C),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        if (cup.isLocked)
          Container(
            width: double.infinity,
            color: Colors.orange.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text('Palpites encerrados',
                    style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchCard(
                match: match,
                home: teams[match.homeTeamId],
                away: teams[match.awayTeamId],
                palpite: palpites[match.id], // null se sem palpite
                locked: cup.isLocked || match.finished,
                isSaving: saving[match.id] ?? false,
                onIncrement: (side) => onIncrement(match.id, side),
                onDecrement: (side) => onDecrement(match.id, side),
                onSave: () => onSaveOne(match),
              );
            },
          ),
        ),
        if (!cup.isLocked)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6B3C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: savingAll ? null : onSaveAll,
                  icon: savingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar todos os palpites',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
