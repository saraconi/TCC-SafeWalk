import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// =============================================
// Safe Walk - Telas de Perfil
// AlterarSenhaScreen e NotificacoesScreen
// =============================================

const Color _kBg      = Color(0xFFF5F0FF);
const Color _kPrimary = Color(0xFF8B1A6B);
const Color _kWhite   = Colors.white;
const Color _kGrey    = Color(0xFF888888);
const Color _kCard    = Color(0xFFFFFFFF);

// ─────────────────────────────────────────────
// Tela de Alterar Senha
// ─────────────────────────────────────────────
class AlterarSenhaScreen extends StatefulWidget {
  final int usuarioId;
  const AlterarSenhaScreen({super.key, required this.usuarioId});

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl  = TextEditingController();
  final _confirmaCtrl   = TextEditingController();
  bool _verAtual   = false;
  bool _verNova    = false;
  bool _verConfirma = false;
  bool _loading    = false;
  String? _erro;
  String? _sucesso;

  Future<void> _alterarSenha() async {
    final senhaAtual = _senhaAtualCtrl.text;
    final novaSenha  = _novaSenhaCtrl.text;
    final confirma   = _confirmaCtrl.text;

    if (senhaAtual.isEmpty || novaSenha.isEmpty || confirma.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    if (novaSenha.length < 6) {
      setState(() => _erro = 'A nova senha deve ter ao menos 6 caracteres.');
      return;
    }
    if (novaSenha != confirma) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() { _loading = true; _erro = null; _sucesso = null; });

    try {
      final url   = 'http://192.168.15.32/safewalk_api/auth.php';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acao':        'alterar_senha',
          'usuario_id':  widget.usuarioId,
          'senha_atual': senhaAtual,
          'nova_senha':  novaSenha,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => _sucesso = 'Senha alterada com sucesso!');
        _senhaAtualCtrl.clear();
        _novaSenhaCtrl.clear();
        _confirmaCtrl.clear();

        // Salva notificação
        await _salvarNotificacao('Senha alterada com sucesso.');
      } else {
        setState(() => _erro = data['erro'] ?? 'Erro desconhecido.');
      }
    } catch (e) {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _kPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alterar senha',
            style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _CampoSenha(
              controller: _senhaAtualCtrl,
              hint: 'Senha atual',
              visivel: _verAtual,
              onToggle: () => setState(() => _verAtual = !_verAtual),
            ),
            const SizedBox(height: 14),
            _CampoSenha(
              controller: _novaSenhaCtrl,
              hint: 'Nova senha',
              visivel: _verNova,
              onToggle: () => setState(() => _verNova = !_verNova),
            ),
            const SizedBox(height: 14),
            _CampoSenha(
              controller: _confirmaCtrl,
              hint: 'Confirme a nova senha',
              visivel: _verConfirma,
              onToggle: () => setState(() => _verConfirma = !_verConfirma),
            ),
            const SizedBox(height: 20),

            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_erro!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            if (_sucesso != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_sucesso!,
                    style: const TextStyle(color: Colors.green, fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _kPrimary))
                  : ElevatedButton(
                      onPressed: _alterarSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: _kWhite,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Salvar nova senha',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoSenha extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool visivel;
  final VoidCallback onToggle;

  const _CampoSenha({
    required this.controller,
    required this.hint,
    required this.visivel,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !visivel,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kGrey),
        prefixIcon: const Icon(Icons.lock_outline, color: _kPrimary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(visivel ? Icons.visibility_off : Icons.visibility,
              color: _kPrimary, size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: _kCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Notificações
// ─────────────────────────────────────────────
class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  List<Map<String, String>> _notificacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList('notificacoes') ?? [];
    setState(() {
      _notificacoes = raw.map((e) {
        final parts = e.split('||');
        return {
          'mensagem': parts.isNotEmpty ? parts[0] : e,
          'data':     parts.length > 1 ? parts[1] : '',
        };
      }).toList().reversed.toList();
    });
  }

  Future<void> _limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notificacoes');
    setState(() => _notificacoes = []);
  }

  IconData _icone(String msg) {
    if (msg.toLowerCase().contains('senha')) return Icons.lock_outline;
    if (msg.toLowerCase().contains('contato')) return Icons.people_outline;
    if (msg.toLowerCase().contains('palavra')) return Icons.record_voice_over_outlined;
    if (msg.toLowerCase().contains('emergência') || msg.toLowerCase().contains('alarme')) {
      return Icons.warning_amber_outlined;
    }
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _kPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notificações',
            style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold)),
        actions: [
          if (_notificacoes.isNotEmpty)
            TextButton(
              onPressed: _limpar,
              child: const Text('Limpar',
                  style: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _notificacoes.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: _kPrimary.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  const Text('Nenhuma notificação ainda.',
                      style: TextStyle(color: _kGrey, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notificacoes.length,
              itemBuilder: (context, i) {
                final n = _notificacoes[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icone(n['mensagem'] ?? ''),
                            color: _kPrimary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['mensagem'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            if ((n['data'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(n['data']!,
                                  style: const TextStyle(
                                      fontSize: 11, color: _kGrey)),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────
// Função global para salvar notificações
// ─────────────────────────────────────────────
Future<void> _salvarNotificacao(String mensagem) async {
  final prefs = await SharedPreferences.getInstance();
  final lista = prefs.getStringList('notificacoes') ?? [];
  final agora = DateTime.now();
  final data  =
      '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} '
      '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';
  lista.add('$mensagem||$data');
  await prefs.setStringList('notificacoes', lista);
}
