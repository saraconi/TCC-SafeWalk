import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// =============================================
// Coloque este arquivo em lib/
// No auth_screens.dart, no botão "Esqueceu sua senha?",
// substitua o onPressed: () {} por:
// onPressed: () => Navigator.push(context,
//   MaterialPageRoute(builder: (_) => const RecuperarSenhaScreen())),
// =============================================

const String _kUrl = 'http://192.168.0.6/safewalk_api/auth.php';
const Color _kBg      = Color(0xFFE8C8F0);
const Color _kPrimary = Color(0xFF8B1A6B);
const Color _kWhite   = Colors.white;
const Color _kFieldBg = Color(0xFFF0E0F8);
const Color _kBorder  = Color(0xFF8B1A6B);
const Color _kGrey    = Color(0xFF888888);

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});
  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  // Etapa 1 = email, 2 = token, 3 = nova senha
  int _etapa = 1;

  final _emailCtrl  = TextEditingController();
  final _tokenCtrl  = TextEditingController();
  final _senhaCtrl  = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _loading = false;
  bool _verSenha = false;
  String? _erro;
  String? _email;

  Future<void> _solicitarCodigo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) { setState(() => _erro = 'Digite seu e-mail.'); return; }
    setState(() { _loading = true; _erro = null; });
    try {
      final r = await http.post(Uri.parse(_kUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'solicitar_recuperacao', 'email': email}),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(r.body);
      if (r.statusCode == 200) {
        setState(() { _email = email; _etapa = 2; });
      } else {
        setState(() => _erro = data['erro'] ?? 'Erro desconhecido.');
      }
    } catch (_) {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verificarToken() async {
    final token = _tokenCtrl.text.trim();
    if (token.length != 6) { setState(() => _erro = 'Digite o código de 6 dígitos.'); return; }
    setState(() { _loading = true; _erro = null; });
    try {
      final r = await http.post(Uri.parse(_kUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'verificar_token', 'email': _email, 'token': token}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(r.body);
      if (r.statusCode == 200) {
        setState(() => _etapa = 3);
      } else {
        setState(() => _erro = data['erro'] ?? 'Código inválido.');
      }
    } catch (_) {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _redefinirSenha() async {
    final senha    = _senhaCtrl.text;
    final confirma = _confirmaCtrl.text;
    if (senha.length < 6) { setState(() => _erro = 'A senha deve ter ao menos 6 caracteres.'); return; }
    if (senha != confirma) { setState(() => _erro = 'As senhas não coincidem.'); return; }
    setState(() { _loading = true; _erro = null; });
    try {
      final r = await http.post(Uri.parse(_kUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'redefinir_senha', 'email': _email,
          'token': _tokenCtrl.text.trim(), 'nova_senha': senha}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(r.body);
      if (r.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Senha redefinida com sucesso! Faça login.'),
          backgroundColor: _kPrimary));
        Navigator.pop(context);
      } else {
        setState(() => _erro = data['erro'] ?? 'Erro desconhecido.');
      }
    } catch (_) {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _tokenCtrl.dispose();
    _senhaCtrl.dispose(); _confirmaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _kPrimary),
          onPressed: () => _etapa > 1
              ? setState(() { _etapa--; _erro = null; })
              : Navigator.pop(context),
        ),
        title: const Text('Recuperar senha',
            style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Indicador de etapas
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Passo(numero: 1, ativo: _etapa >= 1, label: 'E-mail'),
              _LinhaConexao(ativa: _etapa >= 2),
              _Passo(numero: 2, ativo: _etapa >= 2, label: 'Código'),
              _LinhaConexao(ativa: _etapa >= 3),
              _Passo(numero: 3, ativo: _etapa >= 3, label: 'Nova senha'),
            ]),
            const SizedBox(height: 32),

            // Etapa 1 — Email
            if (_etapa == 1) ...[
              const Text('Digite seu e-mail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enviaremos um código de 6 dígitos para redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _kGrey)),
              const SizedBox(height: 28),
              _Campo(controller: _emailCtrl, hint: 'E-mail',
                  icone: Icons.email_outlined, teclado: TextInputType.emailAddress),
            ],

            // Etapa 2 — Token
            if (_etapa == 2) ...[
              const Text('Digite o código', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Enviamos um código de 6 dígitos para $_email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _kGrey)),
              const SizedBox(height: 28),
              TextField(
                controller: _tokenCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                    letterSpacing: 12, color: _kPrimary),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true, fillColor: _kWhite,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _solicitarCodigo,
                child: const Text('Reenviar código',
                    style: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600)),
              ),
            ],

            // Etapa 3 — Nova senha
            if (_etapa == 3) ...[
              const Text('Nova senha', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Digite e confirme sua nova senha.',
                  style: TextStyle(fontSize: 13, color: _kGrey)),
              const SizedBox(height: 28),
              _Campo(controller: _senhaCtrl, hint: 'Nova senha',
                  icone: Icons.lock_outline, obscuro: !_verSenha,
                  sufixo: IconButton(
                    icon: Icon(_verSenha ? Icons.visibility_off : Icons.visibility,
                        color: _kPrimary, size: 20),
                    onPressed: () => setState(() => _verSenha = !_verSenha))),
              const SizedBox(height: 14),
              _Campo(controller: _confirmaCtrl, hint: 'Confirme a nova senha',
                  icone: Icons.lock_outline, obscuro: !_verSenha),
            ],

            const SizedBox(height: 20),

            if (_erro != null) ...[
              Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              const SizedBox(height: 12),
            ],

            // Botão
            _loading
                ? const CircularProgressIndicator(color: _kPrimary)
                : SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _etapa == 1 ? _solicitarCodigo
                          : _etapa == 2 ? _verificarToken
                          : _redefinirSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary, foregroundColor: _kWhite,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                      child: Text(
                        _etapa == 1 ? 'Enviar código'
                            : _etapa == 2 ? 'Verificar código'
                            : 'Salvar nova senha',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final bool obscuro;
  final TextInputType teclado;
  final Widget? sufixo;

  const _Campo({required this.controller, required this.hint,
    required this.icone, this.obscuro = false,
    this.teclado = TextInputType.text, this.sufixo});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, obscureText: obscuro, keyboardType: teclado,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: _kGrey),
        prefixIcon: Icon(icone, color: _kPrimary, size: 20),
        suffixIcon: sufixo,
        filled: true, fillColor: _kFieldBg,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  final int numero;
  final bool ativo;
  final String label;
  const _Passo({required this.numero, required this.ativo, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ativo ? _kPrimary : Colors.white,
          border: Border.all(color: _kPrimary, width: 1.5)),
        child: Center(child: Text('$numero',
            style: TextStyle(color: ativo ? Colors.white : _kPrimary,
                fontWeight: FontWeight.bold, fontSize: 14))),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10,
          color: ativo ? _kPrimary : _kGrey, fontWeight: FontWeight.w500)),
    ]);
  }
}

class _LinhaConexao extends StatelessWidget {
  final bool ativa;
  const _LinhaConexao({required this.ativa});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 2, margin: const EdgeInsets.only(bottom: 16),
      color: ativa ? _kPrimary : Colors.grey.shade300,
    );
  }
}
