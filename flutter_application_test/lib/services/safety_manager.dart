// lib/services/safety_manager.dart
import 'package:flutter/material.dart';

class SafetyManager {
  // --- Limites de Segurança baseados em SST/NR-15 ---
  static const double tempLimiteAlert = 27.0; // °C (Início desconforto térmico)
  static const double tempLimiteCritico = 30.0; // °C

  static const double umidadeMinOk = 30.0; // %
  static const double umidadeMaxOk = 70.0; // % (Acima começa mofo/bactérias)

  static const double ruidoLimiteAlert = 70.0; // dB
  static const double ruidoLimiteCritico = 85.0; // dB (Limite NR-15 p/ 8h)

  // --- Função Única para Avaliar Status e Cor ---
  static Map<String, dynamic> avaliarStatus(String parametro, double valor) {
    switch (parametro) {
      case 'Temperatura':
        if (valor >= tempLimiteCritico) return {'status': 'Crítico', 'cor': Colors.redAccent};
        if (valor >= tempLimiteAlert) return {'status': 'Alerta', 'cor': Colors.orangeAccent};
        return {'status': 'Seguro', 'cor': Colors.greenAccent};

      case 'Umidade':
        // Umidade é "boa" em uma faixa central
        if (valor < umidadeMinOk || valor > umidadeMaxOk) return {'status': 'Alerta', 'cor': Colors.orangeAccent};
        return {'status': 'Seguro', 'cor': Colors.greenAccent};

      case 'Ruído':
        if (valor >= ruidoLimiteCritico) return {'status': 'Crítico', 'cor': Colors.redAccent};
        if (valor >= ruidoLimiteAlert) return {'status': 'Alerta', 'cor': Colors.orangeAccent};
        return {'status': 'Seguro', 'cor': Colors.greenAccent};

      default:
        return {'status': 'Desconhecido', 'cor': Colors.grey};
    }
  }
}