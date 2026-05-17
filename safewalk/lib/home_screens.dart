import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emergency_service.dart';
import 'perfil_screens.dart';

// =============================================
// Safe Walk - Telas principais do app
// Dependências: http: ^1.2.1
// =============================================

const String kDadosUrl = 'http://192.168.15.32/safewalk_api/dados.php';

// Cores
const Color kBg      = Color(0xFFF5F0FF);
const Color kPrimary = Color(0xFF8B1A6B);
const Color kAccent  = Color(0xFFB44FD4);
const Color kWhite   = Colors.white;
const Color kGrey    = Color(0xFF888888);
const Color kCard    = Color(0xFFFFFFFF);

// ─────────────────────────────────────────────
// Shell principal com BottomNavigationBar
// ─────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  final int usuarioId;
  final String usuarioEmail;

  const HomeShell({
    super.key,
    required this.usuarioId,
    required this.usuarioEmail,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<Widget> _telas;

  void _navegarPara(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    _telas = [
      HomeScreen(usuarioId: widget.usuarioId, usuarioEmail: widget.usuarioEmail, onNavigate: _navegarPara),
      AudiosScreen(usuarioId: widget.usuarioId),
      const PalavraChaveScreen(),
      ContatosScreen(usuarioId: widget.usuarioId),
      PerfilScreen(usuarioId: widget.usuarioId, usuarioEmail: widget.usuarioEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: kPrimary,
        unselectedItemColor: kGrey,
        backgroundColor: kWhite,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.mic_none), activeIcon: Icon(Icons.mic), label: 'Áudios'),
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over_outlined), activeIcon: Icon(Icons.record_voice_over), label: 'Palavra-chave'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Contatos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    ));
  }
}

// ─────────────────────────────────────────────
// Tela de Início
// ─────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  final int usuarioId;
  final String usuarioEmail;
  final void Function(int) onNavigate;

  const HomeScreen({super.key, required this.usuarioId, required this.usuarioEmail, required this.onNavigate});

  String get _iniciais {
    final partes = usuarioEmail.split('@')[0].split('.');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return usuarioEmail.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kAccent, kPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(_iniciais,
                    style: const TextStyle(color: kWhite, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Safe Walk',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            const Text('O seu segurança virtual',
                style: TextStyle(fontSize: 13, color: kGrey)),
            const SizedBox(height: 40),

            // Cards de atalho
            _CardAtalho(
              icone: Icons.mic,
              titulo: 'Áudios',
              subtitulo: 'Reproduza seus áudios gravados',
              onTap: () => onNavigate(1),
            ),
            const SizedBox(height: 16),
            _CardAtalho(
              icone: Icons.record_voice_over,
              titulo: 'Palavra-chave',
              subtitulo: 'Configure sua palavra de ativação',
              onTap: () => onNavigate(2),
            ),
            const SizedBox(height: 16),
            _CardAtalho(
              icone: Icons.people,
              titulo: 'Contatos de Emergência',
              subtitulo: 'Gerencie seus contatos de confiança',
              onTap: () => onNavigate(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAtalho extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _CardAtalho({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: kPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(subtitulo, style: const TextStyle(fontSize: 12, color: kGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Áudios
// ─────────────────────────────────────────────
class AudiosScreen extends StatefulWidget {
  final int usuarioId;
  const AudiosScreen({super.key, required this.usuarioId});

  @override
  State<AudiosScreen> createState() => _AudiosScreenState();
}

class _AudiosScreenState extends State<AudiosScreen> {
  List<Map<String, dynamic>> _audios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarAudios();
  }

  Future<void> _carregarAudios() async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse(kDadosUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'listar_audios', 'usuario_id': widget.usuarioId}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      setState(() => _audios = List<Map<String, dynamic>>.from(data['audios'] ?? []));
    } catch (_) {} finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deletarAudio(int id) async {
    await http.post(
      Uri.parse(kDadosUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'acao': 'deletar_audio', 'id': id}),
    );
    _carregarAudios();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                GestureDetector(onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20)),
                const Spacer(),
                Icon(Icons.mic, color: kPrimary, size: 26),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text('Áudios', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text('Confira e reproduza todos os seus áudios gravados.',
                style: TextStyle(fontSize: 13, color: kGrey)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : _audios.isEmpty
                    ? const Center(child: Text('Nenhum áudio gravado ainda.', style: TextStyle(color: kGrey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _audios.length,
                        itemBuilder: (context, i) {
                          final audio = _audios[i];
                          return _CardAudio(
                            nome: audio['nome'] ?? 'Áudio',
                            duracao: audio['duracao'] ?? '00:00',
                            onDelete: () => _deletarAudio(audio['id']),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CardAudio extends StatelessWidget {
  final String nome;
  final String duracao;
  final VoidCallback onDelete;

  const _CardAudio({required this.nome, required this.duracao, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Botão play
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: kWhite, size: 22),
          ),
          const SizedBox(width: 12),
          // Info + waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(duracao, style: const TextStyle(fontSize: 12, color: kGrey)),
                const SizedBox(height: 6),
                // Waveform decorativa
                Row(
                  children: List.generate(24, (i) {
                    final h = [8.0, 14.0, 20.0, 16.0, 10.0, 18.0, 22.0, 12.0][i % 8];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 3,
                      height: h,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Ações
          Column(
            children: [
              Icon(Icons.download_outlined, color: kGrey, size: 20),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline, color: kPrimary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Contatos
// ─────────────────────────────────────────────
class ContatosScreen extends StatefulWidget {
  final int usuarioId;
  const ContatosScreen({super.key, required this.usuarioId});

  @override
  State<ContatosScreen> createState() => _ContatosScreenState();
}

class _ContatosScreenState extends State<ContatosScreen> {
  List<Map<String, dynamic>> _contatos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  Future<void> _carregarContatos() async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse(kDadosUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'listar_contatos', 'usuario_id': widget.usuarioId}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      setState(() => _contatos = List<Map<String, dynamic>>.from(data['contatos'] ?? []));
    } catch (_) {} finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deletarContato(int id) async {
    await http.post(
      Uri.parse(kDadosUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'acao': 'deletar_contato', 'id': id}),
    );
    _carregarContatos();
  }

  void _abrirDialogContato({Map<String, dynamic>? contato}) {
    final nomeCtrl = TextEditingController(text: contato?['nome'] ?? '');
    final telCtrl  = TextEditingController(text: contato?['telefone'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(contato == null ? 'Novo Contato' : 'Editar Contato',
            style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CampoDialog(controller: nomeCtrl, hint: 'Nome completo', icone: Icons.person_outline),
            const SizedBox(height: 12),
            _CampoDialog(controller: telCtrl, hint: 'Telefone', icone: Icons.phone_outlined,
                teclado: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final nome = nomeCtrl.text.trim();
              final tel  = telCtrl.text.trim();
              if (nome.isEmpty || tel.isEmpty) return;
              Navigator.pop(context);
              if (contato == null) {
                await http.post(Uri.parse(kDadosUrl),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'acao': 'adicionar_contato',
                      'usuario_id': widget.usuarioId, 'nome': nome, 'telefone': tel}));
              } else {
                await http.post(Uri.parse(kDadosUrl),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'acao': 'editar_contato',
                      'id': contato['id'], 'nome': nome, 'telefone': tel}));
              }
              _carregarContatos();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  String _iniciais(String nome) {
    final p = nome.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return nome.substring(0, min(2, nome.length)).toUpperCase();
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                GestureDetector(onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _abrirDialogContato(),
                  child: Icon(Icons.add, color: kPrimary, size: 28),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text('Contatos de Emergência',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text('Gerencie seus contatos de confiança para emergências.',
                style: TextStyle(fontSize: 13, color: kGrey)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : _contatos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: kPrimary.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            const Text('Nenhum contato cadastrado.',
                                style: TextStyle(color: kGrey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _contatos.length,
                        itemBuilder: (context, i) {
                          final c = _contatos[i];
                          final cores = [
                            const Color(0xFFD4AEFF),
                            const Color(0xFFAED6F1),
                            const Color(0xFFA9DFBF),
                            const Color(0xFFF9E79F),
                            const Color(0xFFF1948A),
                          ];
                          final cor = cores[i % cores.length];
                          return _CardContato(
                            nome: c['nome'],
                            telefone: c['telefone'],
                            iniciais: _iniciais(c['nome']),
                            corAvatar: cor,
                            onEditar: () => _abrirDialogContato(contato: c),
                            onDeletar: () => _deletarContato(c['id']),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CardContato extends StatelessWidget {
  final String nome;
  final String telefone;
  final String iniciais;
  final Color corAvatar;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const _CardContato({
    required this.nome,
    required this.telefone,
    required this.iniciais,
    required this.corAvatar,
    required this.onEditar,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: corAvatar,
            child: Text(iniciais,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(telefone, style: const TextStyle(fontSize: 12, color: kGrey)),
              ],
            ),
          ),
          GestureDetector(onTap: onEditar,
              child: const Icon(Icons.edit_outlined, color: kGrey, size: 20)),
          const SizedBox(width: 12),
          GestureDetector(onTap: onDeletar,
              child: Icon(Icons.delete_outline, color: kPrimary, size: 20)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Perfil
// ─────────────────────────────────────────────
class PerfilScreen extends StatelessWidget {
  final int usuarioId;
  final String usuarioEmail;

  const PerfilScreen({super.key, required this.usuarioId, required this.usuarioEmail});

  String get _iniciais {
    final p = usuarioEmail.split('@')[0];
    return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar grande
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kAccent, kPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(_iniciais,
                    style: const TextStyle(color: kWhite, fontSize: 32, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 14),
            Text(usuarioEmail,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            Text('Usuário #$usuarioId',
                style: const TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 32),

            // Opções de perfil
            _ItemPerfil(icone: Icons.lock_outline, titulo: 'Alterar senha', onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => AlterarSenhaScreen(usuarioId: usuarioId)));
            }),
            _ItemPerfil(icone: Icons.notifications_outlined, titulo: 'Notificações', onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const NotificacoesScreen()));
            }),
            _ItemPerfil(icone: Icons.info_outline, titulo: 'Sobre o Safe Walk', onTap: () {}),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPerfil extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _ItemPerfil({required this.icone, required this.titulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icone, color: kPrimary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(titulo,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: kGrey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget auxiliar para campos nos dialogs
// ─────────────────────────────────────────────
class _CampoDialog extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final TextInputType teclado;

  const _CampoDialog({
    required this.controller,
    required this.hint,
    required this.icone,
    this.teclado = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icone, color: kPrimary, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F0FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tela de Palavra-chave
// ─────────────────────────────────────────────
class PalavraChaveScreen extends StatefulWidget {
  const PalavraChaveScreen({super.key});

  @override
  State<PalavraChaveScreen> createState() => _PalavraChaveScreenState();
}

class _PalavraChaveScreenState extends State<PalavraChaveScreen> {
  final _palavraCtrl = TextEditingController();
  String? _palavraSalva;
  bool _ativa = false;
  bool _salvando = false;

  static const _kPalavraKey = 'palavra_chave';
  static const _kAtivaKey   = 'palavra_chave_ativa';

  @override
  void initState() {
    super.initState();
    _carregarPrefs();
  }

  Future<void> _carregarPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _palavraSalva = prefs.getString(_kPalavraKey);
      _ativa        = prefs.getBool(_kAtivaKey) ?? false;
      if (_palavraSalva != null) _palavraCtrl.text = _palavraSalva!;
    });
  }

  Future<void> _salvar() async {
    final palavra = _palavraCtrl.text.trim();
    if (palavra.isEmpty) {
      _mostrarSnack('Digite uma palavra ou frase antes de salvar.');
      return;
    }
    if (palavra.split(' ').length > 3) {
      _mostrarSnack('Use no máximo 3 palavras para melhor reconhecimento.');
      return;
    }
    setState(() => _salvando = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPalavraKey, palavra);
    await prefs.setBool(_kAtivaKey, _ativa);
    setState(() { _palavraSalva = palavra; _salvando = false; });
    _mostrarSnack('Palavra-chave salva com sucesso!');
  }

  Future<void> _toggleAtiva(bool value) async {
    print('🔵 Toggle acionado: ligar=$value, _palavraSalva=$_palavraSalva');
    if (_palavraSalva == null || _palavraSalva!.isEmpty) {
      _mostrarSnack('Salve uma palavra-chave antes de ativar.');
      return;
    }
    setState(() => _salvando = true);
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      // Copia o arquivo .ppn dos assets Flutter para o cache do dispositivo
      String keywordPath = _palavraSalva!;
      try {
        final byteData = await rootBundle.load('assets/keyword_files/$_palavraSalva.ppn');
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$_palavraSalva.ppn');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        keywordPath = file.path;
        print('🟢 Arquivo .ppn copiado para: $keywordPath');
      } catch (e) {
        print('🔴 Erro ao copiar .ppn: $e');
        _mostrarSnack('Arquivo de palavra-chave não encontrado.');
        setState(() => _salvando = false);
        return;
      }

      // Busca contatos para SMS
      final uid = prefs.getInt('usuario_id') ?? 0;
      List<String> contatos = [];
      try {
        final response = await http.post(
          Uri.parse(kDadosUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'acao': 'listar_contatos', 'usuario_id': uid}),
        ).timeout(const Duration(seconds: 8));
        final data = jsonDecode(response.body);
        final lista = List<Map<String, dynamic>>.from(data['contatos'] ?? []);
        contatos = lista.map((c) => c['telefone'].toString()).toList();
      } catch (e) {
        print('Erro ao buscar contatos: $e');
      }
      print('🔵 Iniciando serviço com keyword: $keywordPath, contatos: $contatos');
      final ok = await EmergencyServiceBridge.iniciar(
        keyword: keywordPath,
        contatos: contatos,
      );
      print('🟢 Serviço iniciado: $ok');
      setState(() { _ativa = ok; _salvando = false; });
      _mostrarSnack(ok ? 'Safe Walk ativo! Ouvindo em segundo plano.' : 'Erro ao ativar. Verifique as configurações.');
    } else {
      await EmergencyServiceBridge.parar();
      await prefs.setBool(_kAtivaKey, false);
      setState(() { _ativa = false; _salvando = false; });
      _mostrarSnack('Safe Walk desativado.');
    }
  }

  Future<void> _remover() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPalavraKey);
    await prefs.remove(_kAtivaKey);
    setState(() { _palavraSalva = null; _ativa = false; _palavraCtrl.clear(); });
    _mostrarSnack('Palavra-chave removida.');
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  @override
  void dispose() {
    _palavraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.record_voice_over, color: kPrimary, size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Palavra-chave',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Ativação por voz', style: TextStyle(fontSize: 12, color: kGrey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure a palavra ou frase que irá acionar o Safe Walk em segundo plano.',
              style: TextStyle(fontSize: 13, color: kGrey, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _ativa ? kPrimary.withValues(alpha: 0.08) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _ativa ? kPrimary.withValues(alpha: 0.3) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _ativa ? Icons.shield : Icons.shield_outlined,
                    color: _ativa ? kPrimary : kGrey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ativa ? 'Ativação por voz ligada' : 'Ativação por voz desligada',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _ativa ? kPrimary : kGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _palavraSalva != null
                              ? 'Palavra: "$_palavraSalva"'
                              : 'Nenhuma palavra configurada',
                          style: const TextStyle(fontSize: 12, color: kGrey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _ativa,
                    onChanged: _toggleAtiva,
                    activeColor: kPrimary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Campo de palavra-chave
            const Text('Palavra ou frase de ativação',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _palavraCtrl,
              textCapitalization: TextCapitalization.none,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ex: socorro, ajuda, emergência',
                hintStyle: const TextStyle(color: kGrey),
                prefixIcon: const Icon(Icons.mic_outlined, color: kPrimary),
                filled: true,
                fillColor: kCard,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: kPrimary.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kPrimary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 8),

            // Dica
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFFF9A825), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use palavras curtas e únicas (até 3 palavras) para melhor precisão no reconhecimento. Evite palavras muito comuns do dia a dia.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
                ),
                icon: _salvando
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(_salvando ? 'Salvando...' : 'Salvar palavra-chave',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),

            // Botão remover (só aparece se tiver palavra salva)
            if (_palavraSalva != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _remover,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: BorderSide(color: kPrimary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Remover palavra-chave',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Aviso Picovoice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kPrimary.withValues(alpha: 0.15)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: kPrimary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'O reconhecimento de voz utiliza o Porcupine da Picovoice e será ativado em segundo plano após configurar a chave de API.',
                      style: TextStyle(fontSize: 12, color: kPrimary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
