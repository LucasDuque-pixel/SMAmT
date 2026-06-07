class Leitura {
  final double temperatura;
  final double umidade;
  final double ruido; // Agora será tratado como número
  final DateTime dataRegistro;

  Leitura({
    required this.temperatura,
    required this.umidade,
    required this.ruido,
    required this.dataRegistro,
  });

  factory Leitura.fromJson(Map<String, dynamic> json) {
    // Lógica para converter "Apropriado" para um valor numérico seguro (ex: 60dB)
    double converterRuido(dynamic valor) {
      if (valor is num) return valor.toDouble();
      if (valor.toString().toLowerCase() == "apropriado") return 60.0;
      return 0.0;
    }

    return Leitura(
      temperatura: (json['temperatura'] ?? 0).toDouble(),
      umidade: (json['umidade'] ?? 0).toDouble(),
      ruido: converterRuido(json['ruido']),
      // Corrigido para buscar 'data_hora' conforme o seu MongoDB
      dataRegistro: json['data_hora'] != null 
          ? DateTime.parse(json['data_hora']) 
          : DateTime.now(),
    );
  }
}