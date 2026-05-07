import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6), // Lilás moderno
          brightness: Brightness.light,
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFFEC4899),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Fundo neutro claro
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      home: const ImcCalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImcCalculatorScreen extends StatefulWidget {
  const ImcCalculatorScreen({super.key});

  @override
  State<ImcCalculatorScreen> createState() => _ImcCalculatorScreenState();
}

class _ImcCalculatorScreenState extends State<ImcCalculatorScreen>
    with SingleTickerProviderStateMixin {
  double _heightCm = 170.0;
  double _weightKg = 70.0;
  double? _imc;
  String? _classification;
  Color? _resultColor;
  bool _showResult = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  // Cores dinâmicas para classificação
  static const Map<String, Color> _classificationColors = {
    'Abaixo do peso': Color(0xFF06B6D4), // Ciano
    'Peso normal': Color(0xFF10B981), // Verde
    'Sobrepeso': Color(0xFFF59E0B), // Laranja
    'Obesidade': Color(0xFFEF4444), // Vermelho
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getClassification(double imc) {
    if (imc < 18.5) return 'Abaixo do peso';
    if (imc < 25.0) return 'Peso normal';
    if (imc < 30.0) return 'Sobrepeso';
    return 'Obesidade';
  }

  Color _getColor(String classification) => _classificationColors[classification] ?? Colors.grey;

  void _calculateImc() {
    if (_heightCm <= 0 || _weightKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira valores válidos')),
      );
      return;
    }

    setState(() {
      _imc = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
      _classification = _getClassification(_imc!);
      _resultColor = _getColor(_classification!);
      _showResult = true;
    });

    _controller.forward().then((_) => _controller.reverse());
    HapticFeedback.mediumImpact(); // Feedback háptico
  }

  void _reset() {
    setState(() {
      _heightCm = 170.0;
      _weightKg = 70.0;
      _imc = null;
      _classification = null;
      _resultColor = null;
      _showResult = false;
    });
    _controller.reset();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título
            Text(
              'Calculadora de IMC',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.08),

            // Card Altura
            _buildInputCard(
              icon: Icons.height,
              title: 'Altura',
              value: _heightCm,
              min: 100,
              max: 220,
              unit: 'cm',
              onChanged: (value) => setState(() => _heightCm = value),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Card Peso
            _buildInputCard(
              icon: Icons.fitness_center,
              title: 'Peso',
              value: _weightKg,
              min: 30,
              max: 200,
              unit: 'kg',
              onChanged: (value) => setState(() => _weightKg = value),
            ),
            SizedBox(height: screenHeight * 0.06),

            // Botão Calcular
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _calculateImc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                ),
                child: const Text(
                  'CALCULAR IMC',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),

            // Resultado Animado
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                if (!_showResult) return const SizedBox.shrink();
                return Transform.scale(
                  scale: _animation.value,
                  child: _buildResultCard(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF8B5CF6)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) / 5).round(),
                activeColor: const Color(0xFF8B5CF6),
                inactiveColor: Colors.grey.shade300,
                onChanged: onChanged,
              )),
              Text('${value.toStringAsFixed(0)} $unit', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_resultColor!.withOpacity(0.1), _resultColor!.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _resultColor!.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: _resultColor!.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.analytics, size: 60, color: _resultColor),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _imc ?? 0),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                  shadows: [
                    Shadow(color: _resultColor!.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'IMC',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Text(
            _classification ?? '',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _resultColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              label: const Text('REINICIAR', style: TextStyle(color: Colors.grey)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

