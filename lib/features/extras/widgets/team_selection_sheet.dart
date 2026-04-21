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
                '${widget.teamsExcluidos.length} seleção(ões) já escolhida(s)',
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
