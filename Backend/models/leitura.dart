class Leitura {
  final double temperatura;
  final double umidade;
  final double ruido; 
  final DateTime dataRegistro;

  Leitura({
    required this.temperatura,
    required this.umidade,
    required this.ruido,
    required this.dataRegistro,
  });

  factory Leitura.fromJson(Map<String, dynamic> json) {
    // Traduzindo texto do sensor para valor numérico para o gráfico
    double converterRuido(dynamic valor) {
      if (valor is num) return valor.toDouble();
      String s = valor.toString().toLowerCase();
      if (s.contains("ruidoso")) return 85.0; // Valor de alerta
      return 50.0; // Valor seguro
    }

    return Leitura(
      temperatura: (json['temperatura'] ?? 0).toDouble(),
      umidade: (json['umidade'] ?? 0).toDouble(),
      ruido: converterRuido(json['ruido'] ?? "Apropriado"),
      // Corrigindo para o nome exato que vem do seu JSON: 'data_hora'
      dataRegistro: json['data_hora'] != null 
          ? DateTime.parse(json['data_hora']) 
          : DateTime.now(),
    );
  }
}