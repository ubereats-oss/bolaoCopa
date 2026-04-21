import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/extra_question.dart';
import '../../data/repositories/extra_prediction_repository.dart';
import '../../services/firestore_service.dart';
class ManageExtraQuestionsScreen extends StatefulWidget {
  const ManageExtraQuestionsScreen({super.key});
  @override
  State<ManageExtraQuestionsScreen> createState() =>
      _ManageExtraQuestionsScreenState();
}
class _ManageExtraQuestionsScreenState
    extends State<ManageExtraQuestionsScreen> {
  final _repo = ExtraPredictionRepository();
  final _firestoreService = FirestoreService();
  final _db = FirebaseFirestore.instance;
  List<ExtraQuestion> _questions = [];
  String? _cupId;
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
      final questions = await _repo.fetchQuestions(cup.id);
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar perguntas.';
        _loading = false;
      });
    }
  }
  Future<void> _abrirFormulario({ExtraQuestion? question}) async {
    final textCtrl =
        TextEditingController(text: question?.question ?? '');
    ExtraQuestionType tipo = question?.type ?? ExtraQuestionType.team;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                  question == null ? 'Nova Pergunta' : 'Editar Pergunta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pergunta',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tipo de resposta:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  RadioGroup<ExtraQuestionType>(
                    groupValue: tipo,
                    onChanged: (v) {
                      if (v != null) setDialogState(() => tipo = v);
                    },
                    child: const Column(
                      children: [
                        RadioListTile<ExtraQuestionType>(
                          title: Text('Seleção (time)'),
                          value: ExtraQuestionType.team,
                        ),
                        RadioListTile<ExtraQuestionType>(
                          title: Text('Jogador'),
                          value: ExtraQuestionType.player,
                        ),
                      ],
                    ),
                  ),
                ],
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
                    if (textCtrl.text.trim().isEmpty) return;
                    await _salvar(
                      id: question?.id,
                      text: textCtrl.text.trim(),
                      type: tipo,
                      order: question?.order ?? _questions.length,
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
    textCtrl.dispose();
  }
  Future<void> _salvar({
    String? id,
    required String text,
    required ExtraQuestionType type,
    required int order,
  }) async {
    if (_cupId == null) return;
    final ref = _db
        .collection('cups')
        .doc(_cupId)
        .collection('extra_questions');
    final data = {
      'question': text,
      'type': type == ExtraQuestionType.team ? 'team' : 'player',
      'order': order,
    };
    if (id == null) {
      await ref.add(data);
    } else {
      await ref.doc(id).update(data);
    }
    await _carregar();
  }
  Future<void> _excluir(ExtraQuestion question) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir pergunta?'),
        content: Text(question.question),
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
          .collection('extra_questions')
          .doc(question.id)
          .delete();
      await _carregar();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perguntas Extras'),
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
              : _questions.isEmpty
                  ? const Center(child: Text('Nenhuma pergunta cadastrada.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              q.type == ExtraQuestionType.team
                                  ? Icons.flag_outlined
                                  : Icons.person_outline,
                              color: const Color(0xFF1A6B3C),
                            ),
                            title: Text(q.question),
                            subtitle: Text(
                              q.type == ExtraQuestionType.team
                                  ? 'Resposta: Seleção'
                                  : 'Resposta: Jogador',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () =>
                                      _abrirFormulario(question: q),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _excluir(q),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
