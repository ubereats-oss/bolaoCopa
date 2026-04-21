import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/match.dart';
import '../../data/models/team.dart';
import '../../data/repositories/match_repository.dart';
import '../../services/firestore_service.dart';
class ManageMatchesScreen extends StatefulWidget {
  const ManageMatchesScreen({super.key});
  @override
  State<ManageMatchesScreen> createState() => _ManageMatchesScreenState();
}
class _ManageMatchesScreenState extends State<ManageMatchesScreen>
    with SingleTickerProviderStateMixin {
  final _matchRepo = MatchRepository();
  final _firestoreService = FirestoreService();
  late TabController _tabController;
  List<Match> _groupMatches = [];
  List<Match> _knockoutMatches = [];
  Map<String, Team> _teams = {};
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
      final results = await Future.wait([
        _matchRepo.fetchGroupMatches(cup.id),
        _matchRepo.fetchKnockoutMatches(cup.id),
        _matchRepo.fetchTeams(cup.id),
      ]);
      setState(() {
        _groupMatches = results[0] as List<Match>;
        _knockoutMatches = results[1] as List<Match>;
        _teams = results[2] as Map<String, Team>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar jogos.';
        _loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Jogos'),
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
                    _buildList(_groupMatches),
                    _buildList(_knockoutMatches),
                  ],
                ),
    );
  }
  Widget _buildList(List<Match> matches) {
    if (matches.isEmpty) {
      return const Center(child: Text('Nenhum jogo cadastrado.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final home = _teams[match.homeTeamId];
        final away = _teams[match.awayTeamId];
        final dateStr =
            DateFormat('dd/MM/yyyy · HH:mm').format(match.matchTime);
        return Card(
          margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              '${home?.name ?? match.homeTeamId} × ${away?.name ?? match.awayTeamId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dateStr),
            trailing: match.finished
                ? Text(
                    '${match.officialHomeGoals} × ${match.officialAwayGoals}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A6B3C)),
                  )
                : const Text('Pendente',
                    style: TextStyle(color: Colors.grey)),
          ),
        );
      },
    );
  }
}
