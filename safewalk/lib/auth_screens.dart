import 'home_screens.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recuperar_senha_screen.dart';

const String kBaseUrl = 'http://192.168.0.6/safewalk_api/auth.php';

const Color kBgColor      = Color(0xFFE8C8F0);
const Color kPrimary     = Color(0xFF8B1A6B);
const Color kPrimaryLight= Color(0xFFD966BB);
const Color kWhite       = Colors.white;
const Color kFieldBg     = Color(0xFFF0E0F8);
const Color kFieldBorder = Color(0xFF8B1A6B);

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
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

              Expanded(
                flex: 3,
                child: Transform.translate(
                  offset: const Offset(15, 0),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 500,
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeShell(
              usuarioId: data['usuario']['id'],
              usuarioEmail: data['usuario']['email'],
            ),
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

              _CampoTexto(
                controller: _emailCtrl,
                hint: 'Email',
                icone: Icons.email_outlined,
                teclado: TextInputType.emailAddress,
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RecuperarSenhaScreen())),
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              if (_erro != null) ...[
                const SizedBox(height: 4),
                Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              _loading
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : _BotaoPrimario(texto: 'Entrar', onTap: _login),

              const SizedBox(height: 14),

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

  Future<void> _validarEAvancar() async {
    if (_emailCtrl.text.trim().isEmpty || _senhaCtrl.text.isEmpty) {
      setState(() => _erro = 'Por favor, preencha todos os campos.');
      return;
    }

    if (_senhaCtrl.text != _confirmaCtrl.text) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() => _erro = null);

    final aceitouTermos = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TermosScreen()),
    );

    if (aceitouTermos == true) {
      _cadastrar();
    }
  }

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                    : _BotaoPrimario(texto: 'Cadastrar', onTap: _validarEAvancar),

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
      ),
    );
  }
}

// --- Tela customizada e moderna de Termos e Condições ---
class TermosScreen extends StatelessWidget {
  const TermosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho customizado e minimalista
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: kPrimary, size: 20),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Termos e Condições',
                    style: TextStyle(
                      color: kPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card de conteúdo flutuante e com cantos suavizados
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TERMOS DE USO, PRIVACIDADE E RESPONSABILIDADE',
                            style: TextStyle(
                              color: kPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800, // CORRIGIDO: Nome correto da propriedade em camelCase
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ao utilizar a plataforma SafeWalk, você concorda, declara e aceita integralmente as seguintes conditions de uso e suas respectivas implicações legais:',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Color(0xFFF2F2F2), thickness: 1.5),
                          ),

                          _construirSecaoTermos(
                            numero: '1',
                            titulo: 'Finalidade do Aplicativo',
                            corpo: 'O SafeWalk é uma ferramenta tecnológica assistiva desenvolvida com o objetivo estrito de atuar na mitigação de danos e suporte à segurança pessoal de forma discreta.',
                          ),
                          
                          _construirSecaoTermos(
                            numero: '2',
                            titulo: 'Tratamento de Dados Sensíveis (LGPD)',
                            corpo: 'Para o correto funcionamento dos mecanismos de automação e segurança, o aplicativo necessita de autorização prévia, expressa e mandatória para acessar e processar:\n\n'
                                   '• Geolocalização (GPS): Captura e transmissão de coordenadas geográficas em tempo real para os contatos cadastrados no momento da ativação do gatilho.\n\n'
                                   '• Captação de Áudio (Microfone): Monitoramento acústico local e gravação ambiental em segundo plano como forma de registro e preservação de evidências.',
                          ),

                          _construirSecaoTermos(
                            numero: '3',
                            titulo: 'Segurança e Criptografia',
                            corpo: 'Todas as mídias e telemetrias coletadas durante uma ocorrência ativa são tratadas sob estrito sigilo. O armazenamento no servidor é protegido criptograficamente e o acesso posterior ao histórico gerado exige autenticação multifator restrita (incluindo validação por reconhecimento facial).',
                          ),

                          _construirSecaoTermos(
                            numero: '4',
                            titulo: 'Limitação de Responsabilidade Técnica',
                            corpo: 'O SafeWalk não substitui, em hipótese alguma, as forças policiais e os serviços públicos de emergência (como o 190). O aplicativo atua como um canal complementar de aviso para sua rede privada de apoio. A execução do envio de alertas e sincronização de dados depende da disponibilidade de sinal de rede de telefonia/internet móvel e do perfeito funcionamento dos sensores de hardware do próprio dispositivo.',
                          ),

                          _construirSecaoTermos(
                            numero: '5',
                            titulo: 'Consequências do Uso Indevido e Sanções Legais',
                            corpo: 'O SafeWalk foi projetado estritamente como uma tecnologia de salvaguarda à vida e direitos fundamentais. A utilização dos mecanismos de pânico (seja por código ou voz) para fins recreativos, simulações maliciosas, trotes, ou o uso do sistema para monitoramento ilícito de terceiros sujeitará o infrator ao banimento imediato da plataforma e às seguintes sanções previstas na legislação brasileira:\n\n'
                                   '• Falsa Comunicação de Crime (Art. 340 do Código Penal): Provocar a ação de autoridade, polícia ou agentes públicos, comunicando-lhe a ocorrência de crime ou de contravenção que sabe não ter se verificado. Penalidade: Detenção de um a seis meses, ou multa.\n\n'
                                   '• Provocação de Alarme Falso (Art. 41 da Lei de Contravenções Penais): Provocar alarme, produzindo pânico ou tumulto, ou de qualquer modo dar causa a que se desloque inutilmente autoridade ou agente público (como acionamento indevido do 190 via contatos). Penalidade: Prisão simples, de quinze dias a seis meses, ou multa.\n\n'
                                   '• Violação de Privacidade e Interceptação Ilícita: A utilização do recurso de gravação de áudio oculta fora do contexto de legítima defesa para espionar ou registrar conversas alheias sem autorização, bem como a divulgação dessas mídias sem consentimento, viola o Art. 5º, Inciso X da Constituição Federal e as diretrizes da LGPD (Lei nº 13.709/2018), obrigando o infrator a responder civilmente por danos morais e materiais, além de potenciais sanções criminais correlatas.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botões fixos inferiores dispostos lado a lado
              Row(
                children: [
                  Expanded(
                    child: _BotaoSecundario(
                      texto: 'Recusar',
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotaoPrimario(
                      texto: 'Aceitar',
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget utilitário para renderizar as seções numeradas elegantes
  Widget _construirSecaoTermos({required String numero, required String titulo, required String corpo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: kFieldBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    numero,
                    style: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              corpo,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Componentes Compartilhados Reutilizáveis ---
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
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
        child: Text(
          texto,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}