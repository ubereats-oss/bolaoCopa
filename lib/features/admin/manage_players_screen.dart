import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/player.dart';
import '../../data/models/team.dart';
import '../../data/repositories/extra_prediction_repository.dart';
import '../../services/firestore_service.dart';

const _posicoes = ['Goleiro', 'Zagueiro', 'Meia', 'Atacante'];

class ManagePlayersScreen extends StatefulWidget {
  const ManagePlayersScreen({super.key});
  @override
  State<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  final _extraRepo = ExtraPredictionRepository();
  final _firestoreService = FirestoreService();
  final _db = FirebaseFirestore.instance;
  List<Player> _players = [];
  List<Team> _teams = [];
  String? _cupId;
  String? _teamFiltro;
  bool _loading = true;
  String? _erro;

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
      final results = await Future.wait([
        _extraRepo.fetchPlayers(cup.id),
        _extraRepo.fetchTeams(cup.id),
      ]);
      setState(() {
        _players = results[0] as List<Player>;
        _teams = results[1] as List<Team>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar jogadores.';
        _loading = false;
      });
    }
  }

  List<Player> get _filtrados => _teamFiltro == null
      ? _players
      : _players.where((p) => p.teamId == _teamFiltro).toList();

  Future<void> _abrirFormulario({Player? player}) async {
    final nameCtrl = TextEditingController(text: player?.name ?? '');
    String? teamId = player?.teamId ?? _teams.firstOrNull?.id;
    String posicao = player?.position ?? _posicoes.first;
    int numero = player?.number ?? 0;
    bool reserva = player?.reserva ?? false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(player == null ? 'Novo Jogador' : 'Editar Jogador'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do jogador',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: numero.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Número da camisa',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setDialogState(
                          () => numero = int.tryParse(v) ?? numero),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: teamId,
                      decoration: const InputDecoration(
                        labelText: 'Seleção',
                        border: OutlineInputBorder(),
                      ),
                      items: _teams
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              ))
                          .toList(),
                      onChanged: (v) => setDialogState(() => teamId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: posicao,
                      decoration: const InputDecoration(
                        labelText: 'Posição',
                        border: OutlineInputBorder(),
                      ),
                      items: _posicoes
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => posicao = v ?? posicao),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Reserva'),
                      subtitle: const Text(
                          'Não aparece na seleção de jogadores por padrão'),
                      value: reserva,
                      onChanged: (v) => setDialogState(() => reserva = v),
                      activeThumbColor: const Color(0xFF1A6B3C),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6B3C)),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || teamId == null) return;
                    await _salvar(
                      id: player?.id,
                      name: nameCtrl.text.trim(),
                      teamId: teamId!,
                      position: posicao,
                      number: numero,
                      reserva: reserva,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
    nameCtrl.dispose();
  }

  Future<void> _salvar({
    String? id,
    required String name,
    required String teamId,
    required String position,
    required int number,
    required bool reserva,
  }) async {
    if (_cupId == null) return;
    final ref = _db.collection('cups').doc(_cupId).collection('players');
    final data = {
      'name': name,
      'team_id': teamId,
      'position': position,
      'number': number,
      'reserva': reserva,
    };
    if (id == null) {
      await ref.add(data);
    } else {
      await ref.doc(id).update(data);
    }
    await _carregar();
  }

  Future<void> _excluir(Player player) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir jogador?'),
        content: Text(player.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true && _cupId != null) {
      await _db
          .collection('cups')
          .doc(_cupId)
          .collection('players')
          .doc(player.id)
          .delete();
      await _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String?>(
                        initialValue: _teamFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por seleção',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas as seleções'),
                          ),
                          ..._teams.map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              )),
                        ],
                        onChanged: (v) => setState(() => _teamFiltro = v),
                      ),
                    ),
                    Expanded(
                      child: _filtrados.isEmpty
                          ? const Center(
                              child: Text('Nenhum jogador cadastrado.'))
                          : ListView.builder(
                              itemCount: _filtrados.length,
                              itemBuilder: (context, index) {
                                final player = _filtrados[index];
                                final team = _teams.firstWhere(
                                  (t) => t.id == player.teamId,
                                  orElse: () => const Team(
                                      id: '',
                                      name: 'Desconhecida',
                                      flagAsset: ''),
                                );
                                return ListTile(
                                  leading: team.flagAsset.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.asset(
                                            team.flagAsset,
                                            width: 40,
                                            height: 27,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                    Icons.person_outline),
                                          ),
                                        )
                                      : const Icon(Icons.person_outline),
                                  title: Text(player.name),
                                  subtitle: Text(
                                      '${team.name} · Nº ${player.number} · ${player.position}${player.reserva ? ' · Reserva' : ''}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () =>
                                            _abrirFormulario(player: player),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _excluir(player),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
