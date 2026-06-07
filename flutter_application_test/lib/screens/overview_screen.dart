import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/leitura_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import 'home_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeituraProvider>().buscarHistorico(context);
    });
  }

  // Cores Neon para o Dark Mode
  Color _getCorTemp(double temp) => temp >= 30 ? const Color(0xFFFF3366) : (temp >= 27 ? const Color(0xFFFFB020) : const Color(0xFF00E676));
  Color _getCorUmid(double umid) => (umid < 30 || umid > 70) ? const Color(0xFFFFB020) : const Color(0xFF00E676);
  Color _getCorRuido(double ruido) => ruido >= 85 ? const Color(0xFFFF3366) : (ruido >= 70 ? const Color(0xFFFFB020) : const Color(0xFF00E676));

  String _getStatus(Color cor) {
    if (cor == const Color(0xFFFF3366)) return 'ESTADO CRÍTICO';
    if (cor == const Color(0xFFFFB020)) return 'ALERTA';
    return 'SEGURO';
  }

  @override
  Widget build(BuildContext context) {
    // Fundo All-Black Premium (Zinc 950)
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SMAmT // SISTEMA DE MONITORAMENTO', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Color(0xFFFF3366)),
            tooltip: 'Encerrar Sessão',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<LeituraProvider>(
        builder: (context, provider, _) {
          final leituras = provider.historico;
          final ultima = leituras.isNotEmpty ? leituras.last : null;

          if (provider.isLoading && leituras.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Detalhado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("VISÃO GERAL", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5)),
                        const SizedBox(height: 8),
                        Text(
                          "Selecione um módulo para análise telemétrica detalhada.", 
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade400, letterSpacing: 0.5)
                        ),
                      ],
                    ),
                    if (ultima != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sensors, color: Color(0xFF00E676), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "SYNC: ${DateFormat('HH:mm:ss').format(ultima.dataRegistro)}", 
                              style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontFamily: 'monospace')
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 64),
                
                // GRID DOS SEMÁFOROS (Estilo Painel de Controle)
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 40,
                    childAspectRatio: 1.1,
                    children: [
                      _buildSemaforoCard(
                        context, 'TEMPERATURA', Icons.thermostat, 
                        ultima?.temperatura ?? 0, '°C', ultima != null ? _getCorTemp(ultima.temperatura) : Colors.grey.shade800
                      ),
                      _buildSemaforoCard(
                        context, 'UMIDADE', Icons.water_drop, 
                        ultima?.umidade ?? 0, '%', ultima != null ? _getCorUmid(ultima.umidade) : Colors.grey.shade800
                      ),
                      _buildSemaforoCard(
                        context, 'RUÍDO', Icons.graphic_eq, 
                        ultima?.ruido ?? 0, 'dB', ultima != null ? _getCorRuido(ultima.ruido) : Colors.grey.shade800
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSemaforoCard(BuildContext context, String titulo, IconData icone, double valor, String unidade, Color corStatus) {
    return GestureDetector(
      onTap: () {
        // Envia para o gráfico específico mantendo a primeira letra maiúscula para bater com a lógica do HomeScreen
        String paramFormatado = titulo == 'TEMPERATURA' ? 'Temperatura' : titulo == 'UMIDADE' ? 'Umidade' : 'Ruído';
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(parametroAtivoInicial: paramFormatado)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // Fundo escuro levemente texturizado
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF18181B), Color(0xFF09090B)],
          ),
          borderRadius: BorderRadius.circular(24),
          // Borda translúcida elegante
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
          // Efeito de "Underglow" usando a cor do status
          boxShadow: [
            BoxShadow(
              color: corStatus.withOpacity(0.08),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ícone com "Glow"
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: corStatus.withOpacity(0.1), 
                  shape: BoxShape.circle,
                  border: Border.all(color: corStatus.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: corStatus.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)
                  ]
                ),
                child: Icon(icone, size: 64, color: corStatus),
              ),
              
              Column(
                children: [
                  Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(valor.toStringAsFixed(1), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
                      const SizedBox(width: 8),
                      Text(unidade, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Badge de Status Moderno
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: corStatus.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: corStatus.withOpacity(0.5))
                    ),
                    child: Text(_getStatus(corStatus), style: TextStyle(color: corStatus, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}