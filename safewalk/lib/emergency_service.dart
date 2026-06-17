import 'package:flutter/services.dart';

class EmergencyServiceBridge {
  static const _channel = MethodChannel('safewalk/emergency');

  static Future<bool> iniciar({
    required String keyword,
    required List<String> contatos,
  }) async {
    try {
      print('🔵 Chamando iniciarServico com keyword: $keyword');
      final result = await _channel.invokeMethod<bool>('iniciarServico', {
        'keyword': keyword,
        'contatos': contatos,
      });
      print('🟢 Resultado: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print('🔴 Erro ao iniciar serviço: ${e.message}');
      return false;
    } catch (e) {
      print('🔴 Erro inesperado: $e');
      return false;
    }
  }

  static Future<void> parar() async {
    try {
      await _channel.invokeMethod('pararServico');
    } on PlatformException catch (e) {
      print('Erro ao parar serviço: ${e.message}');
    }
  }

  static Future<void> pararGravacao() async {
    try {
      await _channel.invokeMethod('pararGravacao');
    } on PlatformException catch (e) {
      print('Erro ao parar gravação: ${e.message}');
    }
  }

  static Future<void> simularDeteccao() async {
    try {
      print('🔵 Simulando detecção de emergência');
      await _channel.invokeMethod('simularDeteccao');
    } on PlatformException catch (e) {
      print('Erro ao simular: ${e.message}');
    }
  }

  static Future<bool> estaAtivo() async {
    try {
      final result = await _channel.invokeMethod<bool>('servicoAtivo');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> salvarEmailUsuario(String email) async {
    try {
      await _channel.invokeMethod('salvarEmail', {'email': email});
    } on PlatformException catch (e) {
      print('Erro ao salvar email: ${e.message}');
    }
  }
}
