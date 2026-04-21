import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/extra_question.dart';
import '../../data/models/extra_prediction.dart';
import '../../data/models/team.dart';
import '../../data/models/player.dart';
import '../../data/repositories/extra_prediction_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../services/firestore_service.dart';
import 'widgets/question_card.dart';

class ExtraPredictionsScreen extends StatefulWidget {
  final String groupId;

  const ExtraPredictionsScreen({super.key, required this.groupId});

  @override
  State<ExtraPredictionsScreen> createState() =>
      _ExtraPredictionsScreenState();
}

class _ExtraPredictionsScreenState extends State<ExtraPredictionsScreen> {
  final _extraRepo = ExtraPredictionRepository();
  final _firestoreService = FirestoreService();
  late final GroupRepository _groupRepo;

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
    _groupRepo = GroupRepository();
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
        _extraRepo.fetchQuestions(cup.id),
        _groupRepo.fetchAllExtraPredictions(widget.groupId, uid),
        _extraRepo.fetchTeams(cup.id),
        _extraRepo.fetchPlayers(cup.id),
      ]);

      setState(() {
        _questions = results[0] as List<ExtraQuestion>;
        _predictions = results[1] as Map<String, ExtraPrediction>;
        _teams = results[2] as List<Team>;
        _players = results[3] as List<Player>;
        _loading = false;
      });
    } catch (_) {
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
    await _groupRepo.saveExtraPrediction(widget.groupId, prediction);
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
