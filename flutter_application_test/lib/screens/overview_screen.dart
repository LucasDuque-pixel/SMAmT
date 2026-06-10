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
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SMAmT // SISTEMA DE MONITORAMENTO', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: isMobile ? 14 : 16)
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
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24.0 : 48.0, vertical: isMobile ? 16.0 : 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobile 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("VISÃO GERAL", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text("Selecione um módulo para análise.", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                        const SizedBox(height: 16),
                        _buildSyncBadge(ultima),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("VISÃO GERAL", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5)),
                            const SizedBox(height: 8),
                            Text("Selecione um módulo para análise telemétrica detalhada.", style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                          ],
                        ),
                        _buildSyncBadge(ultima),
                      ],
                    ),
                
                SizedBox(height: isMobile ? 32 : 64),
                
                Expanded(
                  child: GridView.count(
                    crossAxisCount: isMobile ? 1 : 3,
                    crossAxisSpacing: isMobile ? 0 : 40,
                    mainAxisSpacing: isMobile ? 24 : 40,
                    childAspectRatio: isMobile ? 1.6 : 1.1,
                    children: [
                      _buildSemaforoCard(context, 'TEMPERATURA', Icons.thermostat, ultima?.temperatura ?? 0, '°C', ultima != null ? _getCorTemp(ultima.temperatura) : Colors.grey.shade800, isMobile),
                      _buildSemaforoCard(context, 'UMIDADE', Icons.water_drop, ultima?.umidade ?? 0, '%', ultima != null ? _getCorUmid(ultima.umidade) : Colors.grey.shade800, isMobile),
                      _buildSemaforoCard(context, 'RUÍDO', Icons.graphic_eq, ultima?.ruido ?? 0, 'dB', ultima != null ? _getCorRuido(ultima.ruido) : Colors.grey.shade800, isMobile),
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

  Widget _buildSyncBadge(dynamic ultima) {
    if (ultima == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sensors, color: Color(0xFF00E676), size: 16),
          const SizedBox(width: 8),
          Text("SYNC: ${DateFormat('HH:mm:ss').format(ultima.dataRegistro)}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildSemaforoCard(BuildContext context, String titulo, IconData icone, double valor, String unidade, Color corStatus, bool isMobile) {
    return GestureDetector(
      onTap: () {
        String paramFormatado = titulo == 'TEMPERATURA' ? 'Temperatura' : titulo == 'UMIDADE' ? 'Umidade' : 'Ruído';
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen(parametroAtivoInicial: paramFormatado)));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF18181B), Color(0xFF09090B)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
          boxShadow: [BoxShadow(color: corStatus.withOpacity(0.08), blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10))],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: corStatus.withOpacity(0.1), shape: BoxShape.circle,
                  border: Border.all(color: corStatus.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: corStatus.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)]
                ),
                child: Icon(icone, size: isMobile ? 48 : 64, color: corStatus),
              ),
              Column(
                children: [
                  Text(titulo, style: TextStyle(fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(valor.toStringAsFixed(1), style: TextStyle(fontSize: isMobile ? 40 : 56, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
                      const SizedBox(width: 8),
                      Text(unidade, style: TextStyle(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ],
                  ),
                  SizedBox(height: isMobile ? 8 : 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: corStatus.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: corStatus.withOpacity(0.5))),
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