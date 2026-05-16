import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================
// Safe Walk - Ponte Flutter ↔ Android
// Comunicação com EmergencyService via MethodChannel
// =============================================

class EmergencyServiceBridge {
  static const _channel = MethodChannel('safewalk/emergency');

  // Inicia o Foreground Service com Porcupine
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

  // Para o Foreground Service completamente
  static Future<void> parar() async {
    try {
      await _channel.invokeMethod('pararServico');
    } on PlatformException catch (e) {
      print('Erro ao parar serviço: ${e.message}');
    }
  }

  // Para só a gravação (mantém Porcupine ouvindo)
  static Future<void> pararGravacao() async {
    try {
      await _channel.invokeMethod('pararGravacao');
    } on PlatformException catch (e) {
      print('Erro ao parar gravação: ${e.message}');
    }
  }

  // Verifica se o serviço está ativo
  static Future<bool> estaAtivo() async {
    try {
      final result = await _channel.invokeMethod<bool>('servicoAtivo');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // Salva o email do usuário nas SharedPreferences nativas
  // (usado pelo EmergencyService para personalizar o SMS)
  static Future<void> salvarEmailUsuario(String email) async {
    try {
      await _channel.invokeMethod('salvarEmail', {'email': email});
    } on PlatformException catch (e) {
      print('Erro ao salvar email: ${e.message}');
    }
  }


}
