import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// =============================================
// Safe Walk - Telas de autenticação
// Dependência: adicione no pubspec.yaml:
//   dependencies:
//     http: ^1.2.1
// =============================================

// URL base da API — 10.0.2.2 = localhost no emulador Android
// Se usar dispositivo físico, troque pelo IP local da sua máquina (ex: 192.168.1.x)
const String kBaseUrl = 'http://10.0.2.2/safewalk_api/auth.php';

// ─────────────────────────────────────────────
// Cores do tema Safe Walk
// ─────────────────────────────────────────────
const Color kBgColor     = Color(0xFFE8C8F0);
const Color kPrimary     = Color(0xFF8B1A6B);
const Color kPrimaryLight= Color(0xFFD966BB);
const Color kWhite       = Colors.white;
const Color kFieldBg     = Color(0xFFF0E0F8);
const Color kFieldBorder = Color(0xFF8B1A6B);

// ─────────────────────────────────────────────
// Tela de Boas-vindas (Welcome)
// ─────────────────────────────────────────────
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Título
              const Text(
                'Safe Walk',
                style: TextStyle(
                  color: kPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'O seu segurança virtual',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // Ilustração placeholder
              Expanded(
                child: Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: kPrimaryLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 100,
                      color: kPrimary,
                    ),
                  ),
                ),
              ),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: _BotaoPrimario(
                      texto: 'Login',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BotaoSecundario(
                      texto: 'Cadastrar',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Login
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _senhaVisivel = false;
  String? _erro;

  Future<void> _login() async {
    setState(() { _loading = true; _erro = null; });

    try {
      final response = await http.post(
        Uri.parse(kBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acao': 'login',
          'email': _emailCtrl.text.trim(),
          'senha': _senhaCtrl.text,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        // Login bem-sucedido — navegue para a tela principal do app
        // Exemplo: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo! ${data['usuario']['email']}'),
            backgroundColor: kPrimary,
          ),
        );
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
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Login',
                      style: TextStyle(
                        color: kPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bem-vindo ao\nseu local seguro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Campo e-mail
              _CampoTexto(
                controller: _emailCtrl,
                hint: 'Email',
                icone: Icons.email_outlined,
                teclado: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Campo senha
              _CampoTexto(
                controller: _senhaCtrl,
                hint: 'Senha',
                icone: Icons.lock_outline,
                obscuro: !_senhaVisivel,
                sufixo: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                    color: kPrimary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                ),
              ),

              // Esqueceu a senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // Erro
              if (_erro != null) ...[
                const SizedBox(height: 4),
                Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              // Botão entrar
              _loading
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : _BotaoPrimario(texto: 'Entrar', onTap: _login),

              const SizedBox(height: 14),

              // Criar conta
              _BotaoSecundario(
                texto: 'Criar conta',
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastroScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Cadastro
// ─────────────────────────────────────────────
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _emailCtrl    = TextEditingController();
  final _senhaCtrl    = TextEditingController();
  final _confirmaCtrl = TextEditingController();
  bool _loading = false;
  bool _senhaVisivel = false;
  bool _confirmaVisivel = false;
  String? _erro;

  Future<void> _cadastrar() async {
    setState(() { _loading = true; _erro = null; });

    try {
      final response = await http.post(
        Uri.parse(kBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acao': 'cadastrar',
          'email': _emailCtrl.text.trim(),
          'senha': _senhaCtrl.text,
          'confirma_senha': _confirmaCtrl.text,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada! Faça login.'),
            backgroundColor: kPrimary,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
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
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Criar conta',
                      style: TextStyle(
                        color: kPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crie sua conta para começar',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _CampoTexto(
                controller: _emailCtrl,
                hint: 'Email',
                icone: Icons.email_outlined,
                teclado: TextInputType.emailAddress,
                ativo: true,
              ),
              const SizedBox(height: 14),

              _CampoTexto(
                controller: _senhaCtrl,
                hint: 'Senha',
                icone: Icons.lock_outline,
                obscuro: !_senhaVisivel,
                sufixo: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                    color: kPrimary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                ),
              ),
              const SizedBox(height: 14),

              _CampoTexto(
                controller: _confirmaCtrl,
                hint: 'Confirme a senha',
                icone: Icons.lock_outline,
                obscuro: !_confirmaVisivel,
                sufixo: IconButton(
                  icon: Icon(
                    _confirmaVisivel ? Icons.visibility_off : Icons.visibility,
                    color: kPrimary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _confirmaVisivel = !_confirmaVisivel),
                ),
              ),

              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],

              const SizedBox(height: 24),

              _loading
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : _BotaoPrimario(texto: 'Cadastrar', onTap: _cadastrar),

              const SizedBox(height: 14),

              _BotaoSecundario(
                texto: 'Já tenho uma conta',
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets reutilizáveis
// ─────────────────────────────────────────────

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final bool obscuro;
  final bool ativo;
  final TextInputType teclado;
  final Widget? sufixo;

  const _CampoTexto({
    required this.controller,
    required this.hint,
    required this.icone,
    this.obscuro = false,
    this.ativo = false,
    this.teclado = TextInputType.text,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        prefixIcon: Icon(icone, color: kPrimary, size: 20),
        suffixIcon: sufixo,
        filled: true,
        fillColor: ativo ? kWhite : kFieldBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ativo ? kFieldBorder : Colors.transparent,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

class _BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _BotaoPrimario({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: Text(texto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _BotaoSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _BotaoSecundario({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kWhite,
          foregroundColor: const Color(0xFF333333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
        ),
        child: Text(texto,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
