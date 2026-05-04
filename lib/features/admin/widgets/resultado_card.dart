import 'package:flutter/material.dart';
import '../../../data/models/match.dart';

class ResultadoImportado {
  final Match? match;
  final int homeGoals;
  final int awayGoals;
  final String nomeCasa;
  final String nomeVisitante;

  const ResultadoImportado({
    required this.match,
    required this.homeGoals,
    required this.awayGoals,
    required this.nomeCasa,
    required this.nomeVisitante,
  });

  bool get encontrado => match != null;
}

class ResultadoCard extends StatelessWidget {
  final ResultadoImportado resultado;

  const ResultadoCard({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final ok = resultado.encontrado;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          ok ? Icons.check_circle_outline : Icons.warning_amber_outlined,
          color: ok ? const Color(0xFF1A6B3C) : Colors.orange,
        ),
        title: Text(
          '${resultado.nomeCasa} × ${resultado.nomeVisitante}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ok ? 'Jogo encontrado' : 'Não encontrado na base',
          style: TextStyle(
            color: ok ? Colors.grey : Colors.orange,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          '${resultado.homeGoals} × ${resultado.awayGoals}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ok ? const Color(0xFF1A6B3C) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
