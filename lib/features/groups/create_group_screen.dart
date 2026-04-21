import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/bolao_group.dart';
import '../../data/repositories/group_repository.dart';
import '../../services/firestore_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _repo = GroupRepository();
  final _firestoreService = FirestoreService();

  bool _loading = false;
  String? _erro;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final cup = await _firestoreService.fetchActiveCup();
      if (cup == null) {
        setState(() {
          _erro = 'Nenhuma copa ativa encontrada.';
          _loading = false;
        });
        return;
      }

      final group = await _repo.createGroup(
        name: _nameCtrl.text.trim(),
        cupId: cup.id,
        adminUid: uid,
      );

      if (mounted) Navigator.pop(context, group);
    } catch (_) {
      if (mounted) {
        setState(() {
          _erro = 'Erro ao criar bolão. Tente novamente.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo bolão'),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crie seu bolão',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Após criar, compartilhe o código de convite com seus amigos.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do bolão',
                  hintText: 'Ex: Bolão da Firma',
                  prefixIcon: Icon(Icons.emoji_events_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o nome do bolão';
                  }
                  if (v.trim().length < 3) {
                    return 'Nome muito curto (mínimo 3 letras)';
                  }
                  return null;
                },
              ),
              if (_erro != null) ...[
                const SizedBox(height: 16),
                Text(_erro!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6B3C),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _loading ? null : _criar,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Criar bolão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
