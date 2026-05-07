import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_screens.dart';

void main() {
  runApp(const IMCApp());
}

class IMCApp extends StatelessWidget {
  const IMCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora IMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        fontFamily: 'Roboto',
      ),
      home: const IMCHomePage(),
    );
  }
}

class IMCHomePage extends StatefulWidget {
  const IMCHomePage({super.key});

  @override
  State<IMCHomePage> createState() => _IMCHomePageState();
}

class _IMCHomePageState extends State<IMCHomePage>
    with SingleTickerProviderStateMixin {
  bool isAdulto = true;
  final TextEditingController _alturaController =
      TextEditingController(text: '170');
  final TextEditingController _pesoController =
      TextEditingController(text: '80.5');

  double? imc;
  String resultado = '';
  Color resultadoColor = const Color(0xFFFFD600);
  late AnimationController _animController;
  late Animation<double> _needleAnimation;
  double _needleTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _needleAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _alturaController.dispose();
    _pesoController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _calcular() {
    final double? altura = double.tryParse(
        _alturaController.text.replaceAll(',', '.'));
    final double? peso =
        double.tryParse(_pesoController.text.replaceAll(',', '.'));

    if (altura == null || peso == null || altura <= 0 || peso <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira valores válidos.')),
      );
      return;
    }

    final double alturaM = altura / 100;
    final double imcCalc = peso / (alturaM * alturaM);

    String res;
    Color cor;
    double needle;

    if (isAdulto) {
      if (imcCalc < 18.5) {
        res = 'Abaixo do peso';
        cor = const Color(0xFF5B9CF6);
        needle = _mapIMC(imcCalc, 10, 18.5, 0.0, 0.20);
      } else if (imcCalc < 25) {
        res = 'Peso normal';
        cor = const Color(0xFF4CAF50);
        needle = _mapIMC(imcCalc, 18.5, 25, 0.20, 0.42);
      } else if (imcCalc < 30) {
        res = 'Sobrepeso';
        cor = const Color(0xFFFFD600);
        needle = _mapIMC(imcCalc, 25, 30, 0.42, 0.62);
      } else if (imcCalc < 35) {
        res = 'Obesidade grau I';
        cor = const Color(0xFFFF9800);
        needle = _mapIMC(imcCalc, 30, 35, 0.62, 0.80);
      } else {
        res = 'Obesidade grau II+';
        cor = const Color(0xFFF44336);
        needle = _mapIMC(imcCalc, 35, 50, 0.80, 1.0);
      }
    } else {
      // Idoso: critérios ligeiramente diferentes
      if (imcCalc < 22) {
        res = 'Abaixo do peso';
        cor = const Color(0xFF5B9CF6);
        needle = _mapIMC(imcCalc, 10, 22, 0.0, 0.25);
      } else if (imcCalc < 27) {
        res = 'Peso normal';
        cor = const Color(0xFF4CAF50);
        needle = _mapIMC(imcCalc, 22, 27, 0.25, 0.50);
      } else if (imcCalc < 30) {
        res = 'Sobrepeso';
        cor = const Color(0xFFFFD600);
        needle = _mapIMC(imcCalc, 27, 30, 0.50, 0.68);
      } else if (imcCalc < 35) {
        res = 'Obesidade grau I';
        cor = const Color(0xFFFF9800);
        needle = _mapIMC(imcCalc, 30, 35, 0.68, 0.85);
      } else {
        res = 'Obesidade grau II+';
        cor = const Color(0xFFF44336);
        needle = _mapIMC(imcCalc, 35, 50, 0.85, 1.0);
      }
    }

    _needleTarget = needle.clamp(0.0, 1.0);
    _needleAnimation = Tween<double>(
      begin: _needleAnimation.value,
      end: _needleTarget,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward(from: 0);

    setState(() {
      imc = imcCalc;
      resultado = res;
      resultadoColor = cor;
    });
  }

  double _mapIMC(
      double value, double inMin, double inMax, double outMin, double outMax) {
    return outMin + (value - inMin) / (inMax - inMin) * (outMax - outMin);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                const Text(
                  'Calculadora IMC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O IMC (Índice de Massa Corporal) é um cálculo que\nserve para avaliar se a pessoa está dentro do seu peso ideal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                // Toggle Adulto / Idoso
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildToggleButton('Adulto', isAdulto, () {
                        setState(() => isAdulto = true);
                      }),
                      _buildToggleButton('Idoso', !isAdulto, () {
                        setState(() => isAdulto = false);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Campo Altura
                _buildInputField('Altura', _alturaController, 'cm'),
                const SizedBox(height: 10),

                // Campo Peso
                _buildInputField('Peso', _pesoController, 'kg'),
                const SizedBox(height: 12),

                // Botão calcular
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _calcular,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.black, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Resultado texto
                if (imc != null) ...[
                  Text(
                    'IMC: ${imc!.toStringAsFixed(1)}  •  $resultado',
                    style: TextStyle(
                      color: resultadoColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Preencha os campos e pressione ✓',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 4),

                // Gráfico de medidor (gauge)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _needleAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: GaugePainter(
                          progress: _needleAnimation.value,
                          isAdulto: isAdulto,
                        ),
                        child: Container(),
                      );
                    },
                  ),
                ),

                // Legenda
                _buildLegend(),
                const SizedBox(height: 10),

                // Botão discreto de interrogação (canto direito)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3A3A52),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.question_mark_rounded,
                        color: Color(0xFF666688),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFD600) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD600), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              ],
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final items = isAdulto
        ? [
            ('< 18.5', const Color(0xFF5B9CF6), 'Abaixo'),
            ('18.5–24.9', const Color(0xFF4CAF50), 'Normal'),
            ('25–29.9', const Color(0xFFFFD600), 'Sobrepeso'),
            ('30–34.9', const Color(0xFFFF9800), 'Ob. I'),
            ('≥ 35', const Color(0xFFF44336), 'Ob. II+'),
          ]
        : [
            ('< 22', const Color(0xFF5B9CF6), 'Abaixo'),
            ('22–26.9', const Color(0xFF4CAF50), 'Normal'),
            ('27–29.9', const Color(0xFFFFD600), 'Sobrepeso'),
            ('30–34.9', const Color(0xFFFF9800), 'Ob. I'),
            ('≥ 35', const Color(0xFFF44336), 'Ob. II+'),
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map((item) => Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.$2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.$3,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 9)),
                  Text(item.$1,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 8)),
                ],
              ))
          .toList(),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final bool isAdulto;

  GaugePainter({required this.progress, required this.isAdulto});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.78;
    final radius = min(size.width * 0.42, size.height * 0.68);
    final strokeW = radius * 0.22;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    const startAngle = pi;
    const sweepAngle = pi;

    // Segmentos de cor
    final segments = [
      (const Color(0xFF5B9CF6), 0.20),
      (const Color(0xFF4CAF50), 0.22),
      (const Color(0xFFFFD600), 0.20),
      (const Color(0xFFFF9800), 0.18),
      (const Color(0xFFF44336), 0.20),
    ];

    double currentAngle = startAngle;
    for (final seg in segments) {
      final sweep = sweepAngle * seg.$2;
      final paint = Paint()
        ..color = seg.$1
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, currentAngle, sweep, false, paint);
      currentAngle += sweep;
    }

    // Gaps entre segmentos
    final gapPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 2
      ..strokeCap = StrokeCap.butt;

    double gapAngle = startAngle;
    for (int i = 0; i < segments.length - 1; i++) {
      gapAngle += sweepAngle * segments[i].$2;
      canvas.drawArc(
          rect, gapAngle - 0.012, 0.024, false, gapPaint);
    }

    // Trilho de fundo (arco externo fino)
    final trackPaint = Paint()
      ..color = const Color(0xFF2A2A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(cx, cy), radius: radius + strokeW / 2 + 3),
        startAngle,
        sweepAngle,
        false,
        trackPaint);
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(cx, cy), radius: radius - strokeW / 2 - 3),
        startAngle,
        sweepAngle,
        false,
        trackPaint);

    // Agulha
    final needleAngle = startAngle + sweepAngle * progress;
    final needleLen = radius + strokeW / 2 + 6;
    final needleBase = radius - strokeW / 2 - 6;
    final nx = cx + cos(needleAngle) * needleLen;
    final ny = cy + sin(needleAngle) * needleLen;
    final nbx = cx + cos(needleAngle) * needleBase;
    final nby = cy + sin(needleAngle) * needleBase;

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(nbx, nby), Offset(nx, ny), needlePaint);

    // Centro da agulha
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 7, centerPaint);
    canvas.drawCircle(Offset(cx, cy), 4,
        Paint()..color = const Color(0xFF1A1A2E));

    // Rótulos mínimo e máximo
    final labelStyle = const TextStyle(
      color: Colors.white54,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );

    _drawText(canvas, isAdulto ? '10' : '10',
        Offset(cx - radius - strokeW / 2 - 4, cy + 8), labelStyle);
    _drawText(canvas, '50+',
        Offset(cx + radius + strokeW / 2 - 12, cy + 8), labelStyle);
  }

  void _drawText(
      Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isAdulto != isAdulto;
}