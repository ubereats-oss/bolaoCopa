"""
Refatoração: extração de widgets para arquivos separados.
Reduz arquivos grandes para menos de 300 linhas cada.

Execute na raiz do projeto Flutter:
  python refatorar_widgets.py
"""

import os

def escrever(caminho, conteudo):
    os.makedirs(os.path.dirname(caminho), exist_ok=True)
    with open(caminho, 'w', encoding='utf-8') as f:
        f.write(conteudo)
    linhas = conteudo.count('\n')
    print(f'  ✓ {caminho} ({linhas} linhas)')

# ═══════════════════════════════════════════════════════════════════════════════
# MATCHES — widgets
# ═══════════════════════════════════════════════════════════════════════════════

escrever('lib/features/matches/widgets/team_block.dart', '''\
import 'package:flutter/material.dart';
import '../../../data/models/team.dart';

class TeamBlock extends StatelessWidget {
  final Team? team;
  final bool alignRight;

  const TeamBlock({super.key, required this.team, this.alignRight = false});

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
          team?.name ?? '?',
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
''')

escrever('lib/features/matches/widgets/score_control.dart', '''\
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
''')

escrever('lib/features/matches/widgets/match_card.dart', '''\
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/match.dart';
import '../../../data/models/team.dart';
import 'team_block.dart';
import 'score_control.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final Team? home;
  final Team? away;
  final List<int> palpite;
  final bool locked;
  final bool isSaving;
  final void Function(int side) onIncrement;
  final void Function(int side) onDecrement;
  final VoidCallback onSave;

  const MatchCard({
    super.key,
    required this.match,
    required this.home,
    required this.away,
    required this.palpite,
    required this.locked,
    required this.isSaving,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy · HH:mm').format(match.matchTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(dateStr,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TeamBlock(team: home)),
                ScoreControl(
                  homeGoals: palpite[0],
                  awayGoals: palpite[1],
                  locked: locked,
                  onIncrementHome: () => onIncrement(0),
                  onDecrementHome: () => onDecrement(0),
                  onIncrementAway: () => onIncrement(1),
                  onDecrementAway: () => onDecrement(1),
                ),
                Expanded(child: TeamBlock(team: away, alignRight: true)),
              ],
            ),
            const SizedBox(height: 10),
            if (match.finished)
              Text(
                'Resultado oficial: '
                '${match.officialHomeGoals} × ${match.officialAwayGoals}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A6B3C),
                    fontSize: 13),
              )
            else if (!locked)
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
                      : const Text('Salvar este palpite'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
''')

escrever('lib/features/matches/widgets/match_list_tab.dart', '''\
import 'package:flutter/material.dart';
import '../../../data/models/match.dart';
import '../../../data/models/team.dart';
import '../../../data/models/cup.dart';
import 'match_card.dart';

class MatchListTab extends StatelessWidget {
  final List<Match> matches;
  final Map<String, Team> teams;
  final Cup cup;
  final Map<String, List<int>> palpites;
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
                palpite: palpites[match.id] ?? [0, 0],
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
''')

# matches_screen.dart reescrito
escrever('lib/features/matches/matches_screen.dart', '''\
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/match.dart';
import '../../data/models/team.dart';
import '../../data/models/cup.dart';
import '../../data/models/prediction.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/prediction_repository.dart';
import '../../services/firestore_service.dart';
import 'widgets/match_list_tab.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  final _matchRepo = MatchRepository();
  final _predictionRepo = PredictionRepository();
  final _firestoreService = FirestoreService();
  late TabController _tabController;

  List<Match> _groupMatches = [];
  List<Match> _knockoutMatches = [];
  Map<String, Team> _teams = {};
  Cup? _cup;
  final Map<String, List<int>> _palpites = {};
  final Map<String, bool> _saving = {};
  bool _savingAll = false;
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final cup = await _firestoreService.fetchActiveCup();
      if (cup == null) {
        setState(() {
          _erro = 'Nenhum bolão ativo encontrado.';
          _loading = false;
        });
        return;
      }
      _cup = cup;

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final results = await Future.wait([
        _matchRepo.fetchGroupMatches(cup.id),
        _matchRepo.fetchKnockoutMatches(cup.id),
        _matchRepo.fetchTeams(cup.id),
        _predictionRepo.fetchAllPredictions(uid),
      ]);

      final groupMatches = results[0] as List<Match>;
      final knockoutMatches = results[1] as List<Match>;
      final teams = results[2] as Map<String, Team>;
      final predictions = results[3] as List<Prediction>;

      final Map<String, List<int>> palpites = {};
      for (final p in predictions) {
        palpites[p.matchId] = [p.homeGoals, p.awayGoals];
      }
      for (final m in [...groupMatches, ...knockoutMatches]) {
        palpites.putIfAbsent(m.id, () => [0, 0]);
      }

      setState(() {
        _groupMatches = groupMatches;
        _knockoutMatches = knockoutMatches;
        _teams = teams;
        _palpites.addAll(palpites);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar jogos.';
        _loading = false;
      });
    }
  }

  void _incrementar(String matchId, int side) {
    if (_cup?.isLocked ?? true) return;
    setState(() {
      _palpites[matchId]![side] =
          (_palpites[matchId]![side] + 1).clamp(0, 99);
    });
  }

  void _decrementar(String matchId, int side) {
    if (_cup?.isLocked ?? true) return;
    setState(() {
      _palpites[matchId]![side] =
          (_palpites[matchId]![side] - 1).clamp(0, 99);
    });
  }

  Future<void> _salvarUm(Match match) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() => _saving[match.id] = true);
    try {
      final gols = _palpites[match.id]!;
      await _predictionRepo.savePrediction(Prediction(
        matchId: match.id,
        userId: uid,
        homeGoals: gols[0],
        awayGoals: gols[1],
        savedAt: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Palpite salvo!'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFF1A6B3C),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao salvar palpite.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving[match.id] = false);
    }
  }

  Future<void> _salvarTodos(List<Match> matches) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() => _savingAll = true);
    try {
      for (final match in matches) {
        final gols = _palpites[match.id]!;
        await _predictionRepo.savePrediction(Prediction(
          matchId: match.id,
          userId: uid,
          homeGoals: gols[0],
          awayGoals: gols[1],
          savedAt: DateTime.now(),
        ));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(\'${matches.length} palpites salvos!\'),
          backgroundColor: const Color(0xFF1A6B3C),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao salvar palpites.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _savingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Palpites'),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Fase de Grupos'),
            Tab(text: 'Mata-Mata'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    MatchListTab(
                      matches: _groupMatches,
                      teams: _teams,
                      cup: _cup!,
                      palpites: _palpites,
                      saving: _saving,
                      savingAll: _savingAll,
                      onIncrement: _incrementar,
                      onDecrement: _decrementar,
                      onSaveOne: _salvarUm,
                      onSaveAll: () => _salvarTodos(_groupMatches),
                    ),
                    MatchListTab(
                      matches: _knockoutMatches,
                      teams: _teams,
                      cup: _cup!,
                      palpites: _palpites,
                      saving: _saving,
                      savingAll: _savingAll,
                      onIncrement: _incrementar,
                      onDecrement: _decrementar,
                      onSaveOne: _salvarUm,
                      onSaveAll: () => _salvarTodos(_knockoutMatches),
                    ),
                  ],
                ),
    );
  }
}
''')

# ═══════════════════════════════════════════════════════════════════════════════
# EXTRAS — widgets
# ═══════════════════════════════════════════════════════════════════════════════

escrever('lib/features/extras/widgets/question_card.dart', '''\
import 'package:flutter/material.dart';
import '../../../data/models/extra_question.dart';
import '../../../data/models/extra_prediction.dart';
import '../../../data/models/team.dart';
import '../../../data/models/player.dart';
import 'team_selection_sheet.dart';
import 'player_selection_sheet.dart';

class QuestionCard extends StatelessWidget {
  final ExtraQuestion question;
  final ExtraPrediction? prediction;
  final List<Team> teams;
  final List<Player> players;
  final bool locked;
  final Set<String> teamsExcluidos;
  final Future<void> Function(String answer) onSave;

  const QuestionCard({
    super.key,
    required this.question,
    required this.prediction,
    required this.teams,
    required this.players,
    required this.locked,
    required this.teamsExcluidos,
    required this.onSave,
  });

  Future<void> _abrirSelecao(BuildContext context) async {
    if (locked) return;

    if (question.type == ExtraQuestionType.team) {
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => TeamSelectionSheet(
          title: question.question,
          teams: teams,
          selectedId: prediction?.answer,
          teamsExcluidos: teamsExcluidos,
        ),
      );
      if (result != null) await onSave(result);
    } else {
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => PlayerSelectionSheet(
          title: question.question,
          teams: teams,
          players: players,
          selectedPlayerId: prediction?.answer,
        ),
      );
      if (result != null) await onSave(result);
    }
  }

  String _labelResposta() {
    if (prediction == null || prediction!.answer.isEmpty) {
      return 'Toque para responder';
    }
    if (question.type == ExtraQuestionType.team) {
      return teams
          .firstWhere((t) => t.id == prediction!.answer,
              orElse: () =>
                  const Team(id: '', name: 'Desconhecido', flagAsset: ''))
          .name;
    }
    final player = players.firstWhere(
      (p) => p.id == prediction!.answer,
      orElse: () => const Player(id: '', name: 'Desconhecido', teamId: ''),
    );
    final team = teams.firstWhere(
      (t) => t.id == player.teamId,
      orElse: () => const Team(id: '', name: '', flagAsset: ''),
    );
    return team.name.isNotEmpty ? \'${player.name} (${team.name})\' : player.name;
  }

  Widget _leading() {
    if (prediction == null || prediction!.answer.isEmpty) {
      return const Icon(Icons.help_outline, size: 32, color: Colors.grey);
    }
    String? flagAsset;
    if (question.type == ExtraQuestionType.team) {
      flagAsset = teams
          .firstWhere((t) => t.id == prediction!.answer,
              orElse: () => const Team(id: '', name: '', flagAsset: ''))
          .flagAsset;
    } else {
      final player = players.firstWhere(
        (p) => p.id == prediction!.answer,
        orElse: () => const Player(id: '', name: '', teamId: ''),
      );
      flagAsset = teams
          .firstWhere((t) => t.id == player.teamId,
              orElse: () => const Team(id: '', name: '', flagAsset: ''))
          .flagAsset;
    }
    if (flagAsset == null || flagAsset.isEmpty) {
      return Icon(
        question.type == ExtraQuestionType.team
            ? Icons.flag_outlined
            : Icons.person_outline,
        size: 32,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(flagAsset,
          width: 48,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.flag_outlined, size: 32)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final respondido = prediction != null && prediction!.answer.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: _leading(),
        title: Text(question.question,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          _labelResposta(),
          style: TextStyle(
              color: respondido ? const Color(0xFF1A6B3C) : Colors.grey),
        ),
        trailing: locked
            ? const Icon(Icons.lock_outline, color: Colors.orange)
            : const Icon(Icons.chevron_right),
        onTap: locked ? null : () => _abrirSelecao(context),
      ),
    );
  }
}
''')

escrever('lib/features/extras/widgets/team_selection_sheet.dart', '''\
import 'package:flutter/material.dart';
import '../../../data/models/team.dart';

class TeamSelectionSheet extends StatefulWidget {
  final String title;
  final List<Team> teams;
  final String? selectedId;
  final Set<String> teamsExcluidos;

  const TeamSelectionSheet({
    super.key,
    required this.title,
    required this.teams,
    required this.selectedId,
    required this.teamsExcluidos,
  });

  @override
  State<TeamSelectionSheet> createState() => _TeamSelectionSheetState();
}

class _TeamSelectionSheetState extends State<TeamSelectionSheet> {
  final _searchController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height * 0.75;
    final disponiveis = widget.teams
        .where((t) =>
            !widget.teamsExcluidos.contains(t.id) &&
            t.name.toLowerCase().contains(_busca.toLowerCase()))
        .toList();

    return SizedBox(
      height: altura,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          if (widget.teamsExcluidos.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                \'${widget.teamsExcluidos.length} seleção(ões) já escolhida(s)\',
                style:
                    const TextStyle(fontSize: 12, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar seleção...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _busca = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: disponiveis.isEmpty
                ? const Center(child: Text('Nenhuma seleção disponível.'))
                : ListView.builder(
                    itemCount: disponiveis.length,
                    itemBuilder: (context, index) {
                      final team = disponiveis[index];
                      final selected = widget.selectedId == team.id;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(team.flagAsset,
                              width: 40,
                              height: 27,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.flag_outlined)),
                        ),
                        title: Text(team.name),
                        trailing: selected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF1A6B3C))
                            : null,
                        onTap: () => Navigator.pop(context, team.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
''')

escrever('lib/features/extras/widgets/player_selection_sheet.dart', '''\
import 'package:flutter/material.dart';
import '../../../data/models/team.dart';
import '../../../data/models/player.dart';

class PlayerSelectionSheet extends StatefulWidget {
  final String title;
  final List<Team> teams;
  final List<Player> players;
  final String? selectedPlayerId;

  const PlayerSelectionSheet({
    super.key,
    required this.title,
    required this.teams,
    required this.players,
    required this.selectedPlayerId,
  });

  @override
  State<PlayerSelectionSheet> createState() => _PlayerSelectionSheetState();
}

class _PlayerSelectionSheetState extends State<PlayerSelectionSheet> {
  final _searchController = TextEditingController();
  String? _teamFiltro;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedPlayerId != null) {
      final player = widget.players.firstWhere(
        (p) => p.id == widget.selectedPlayerId,
        orElse: () => const Player(id: '', name: '', teamId: ''),
      );
      if (player.teamId.isNotEmpty) _teamFiltro = player.teamId;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Player> get _filtrados => widget.players.where((p) {
        final matchTeam = _teamFiltro == null || p.teamId == _teamFiltro;
        final matchBusca =
            p.name.toLowerCase().contains(_busca.toLowerCase());
        return matchTeam && matchBusca;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height * 0.85;
    final teamSelecionado = _teamFiltro == null
        ? null
        : widget.teams.firstWhere((t) => t.id == _teamFiltro,
            orElse: () => const Team(id: '', name: '', flagAsset: ''));

    return SizedBox(
      height: altura,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (teamSelecionado != null &&
                    teamSelecionado.flagAsset.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(teamSelecionado.flagAsset,
                          width: 36, height: 24, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox()),
                    ),
                  ),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _teamFiltro,
                    decoration: const InputDecoration(
                      labelText: 'Selecione a seleção',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('Todas as seleções')),
                      ...widget.teams.map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.name),
                          )),
                    ],
                    onChanged: (v) => setState(() {
                      _teamFiltro = v;
                      _busca = '';
                      _searchController.clear();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar jogador...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _busca = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _teamFiltro == null
                ? const Center(
                    child: Text(
                      'Selecione uma seleção acima\\npara ver os jogadores',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _filtrados.isEmpty
                    ? const Center(child: Text('Nenhum jogador encontrado.'))
                    : ListView.builder(
                        itemCount: _filtrados.length,
                        itemBuilder: (context, index) {
                          final player = _filtrados[index];
                          final team = widget.teams.firstWhere(
                            (t) => t.id == player.teamId,
                            orElse: () =>
                                const Team(id: '', name: '', flagAsset: ''),
                          );
                          final selected =
                              widget.selectedPlayerId == player.id;
                          return ListTile(
                            leading: team.flagAsset.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.asset(team.flagAsset,
                                        width: 40, height: 27,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.person_outline)),
                                  )
                                : const Icon(Icons.person_outline),
                            title: Text(player.name),
                            subtitle: Text(team.name),
                            trailing: selected
                                ? const Icon(Icons.check_circle,
                                    color: Color(0xFF1A6B3C))
                                : null,
                            onTap: () => Navigator.pop(context, player.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
''')

# extra_predictions_screen reescrito
escrever('lib/features/extras/extra_predictions_screen.dart', '''\
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/extra_question.dart';
import '../../data/models/extra_prediction.dart';
import '../../data/models/team.dart';
import '../../data/models/player.dart';
import '../../data/repositories/extra_prediction_repository.dart';
import '../../services/firestore_service.dart';
import 'widgets/question_card.dart';

class ExtraPredictionsScreen extends StatefulWidget {
  const ExtraPredictionsScreen({super.key});

  @override
  State<ExtraPredictionsScreen> createState() =>
      _ExtraPredictionsScreenState();
}

class _ExtraPredictionsScreenState extends State<ExtraPredictionsScreen> {
  final _repo = ExtraPredictionRepository();
  final _firestoreService = FirestoreService();

  List<ExtraQuestion> _questions = [];
  Map<String, ExtraPrediction> _predictions = {};
  List<Team> _teams = [];
  List<Player> _players = [];
  bool _locked = false;
  bool _loading = true;
  String? _erro;
  String? _cupId;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final cup = await _firestoreService.fetchActiveCup();
      if (cup == null) {
        setState(() {
          _erro = 'Nenhum bolão ativo encontrado.';
          _loading = false;
        });
        return;
      }
      _cupId = cup.id;
      _locked = cup.isLocked;
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final results = await Future.wait([
        _repo.fetchQuestions(cup.id),
        _repo.fetchUserPredictions(uid),
        _repo.fetchTeams(cup.id),
        _repo.fetchPlayers(cup.id),
      ]);

      setState(() {
        _questions = results[0] as List<ExtraQuestion>;
        _predictions = results[1] as Map<String, ExtraPrediction>;
        _teams = results[2] as List<Team>;
        _players = results[3] as List<Player>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar perguntas.';
        _loading = false;
      });
    }
  }

  Future<void> _salvar(String questionId, String answer) async {
    if (_locked || _cupId == null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prediction = ExtraPrediction(
      questionId: questionId,
      userId: uid,
      answer: answer,
      savedAt: DateTime.now(),
    );
    await _repo.savePrediction(prediction);
    setState(() => _predictions[questionId] = prediction);
  }

  Set<String> _teamsJaEscolhidos(String questionIdAtual) {
    final Set<String> usados = {};
    for (final q in _questions) {
      if (q.type == ExtraQuestionType.team && q.id != questionIdAtual) {
        final pred = _predictions[q.id];
        if (pred != null && pred.answer.isNotEmpty) usados.add(pred.answer);
      }
    }
    return usados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palpites Extras'),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_questions.isEmpty) {
      return const Center(child: Text('Nenhuma pergunta disponível.'));
    }
    return Column(
      children: [
        if (_locked)
          Container(
            width: double.infinity,
            color: Colors.orange.withValues(alpha: 0.1),
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Text('A Copa já começou. Palpites encerrados.',
                    style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return QuestionCard(
                question: question,
                prediction: _predictions[question.id],
                teams: _teams,
                players: _players,
                locked: _locked,
                teamsExcluidos: question.type == ExtraQuestionType.team
                    ? _teamsJaEscolhidos(question.id)
                    : {},
                onSave: (answer) => _salvar(question.id, answer),
              );
            },
          ),
        ),
      ],
    );
  }
}
''')

print()
print('=' * 55)
print('  Refatoração concluída!')
print()
print('  Novos arquivos criados:')
print('  lib/features/matches/widgets/team_block.dart')
print('  lib/features/matches/widgets/score_control.dart')
print('  lib/features/matches/widgets/match_card.dart')
print('  lib/features/matches/widgets/match_list_tab.dart')
print('  lib/features/extras/widgets/question_card.dart')
print('  lib/features/extras/widgets/team_selection_sheet.dart')
print('  lib/features/extras/widgets/player_selection_sheet.dart')
print()
print('  Arquivos reduzidos:')
print('  lib/features/matches/matches_screen.dart')
print('  lib/features/extras/extra_predictions_screen.dart')
print()
print('  Agora rode: flutter analyze')
print('=' * 55)
