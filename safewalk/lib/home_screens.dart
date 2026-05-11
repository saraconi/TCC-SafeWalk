import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// =============================================
// Safe Walk - Telas principais do app
// Dependências: http: ^1.2.1
// =============================================

const String kDadosUrl = 'http://10.0.2.2/safewalk_api/dados.php';

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
      body: _telas[_currentIndex],
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
              icone: Icons.people,
              titulo: 'Contatos de Emergência',
              subtitulo: 'Gerencie seus contatos de confiança',
              onTap: () => onNavigate(2),
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
            _ItemPerfil(icone: Icons.lock_outline, titulo: 'Alterar senha', onTap: () {}),
            _ItemPerfil(icone: Icons.notifications_outlined, titulo: 'Notificações', onTap: () {}),
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