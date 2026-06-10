import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/leitura_provider.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  final String parametroAtivoInicial;
  
  const HomeScreen({super.key, this.parametroAtivoInicial = 'Temperatura'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _parametroAtivo;

  @override
  void initState() {
    super.initState();
    _parametroAtivo = widget.parametroAtivoInicial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeituraProvider>().buscarHistorico(context);
    });
  }

  Color _getCorTemp(double temp) => temp >= 30 ? const Color(0xFFFF3366) : (temp >= 27 ? const Color(0xFFFFB020) : const Color(0xFF00E676));
  Color _getCorUmid(double umid) => (umid < 30 || umid > 70) ? const Color(0xFFFFB020) : const Color(0xFF00E676);
  Color _getCorRuido(double ruido) => ruido >= 85 ? const Color(0xFFFF3366) : (ruido >= 70 ? const Color(0xFFFFB020) : const Color(0xFF00E676));

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF18181B),
              child: _buildSidebar(
                context.watch<LeituraProvider>().historico.isNotEmpty
                    ? context.watch<LeituraProvider>().historico.last
                    : null, 
                isMobile
              ),
            )
          : null,
          
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF09090B),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              title: const Text(
                "SMAmT TELEMETRIA",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            )
          : null,
          
      body: Consumer<LeituraProvider>(
        builder: (context, provider, _) {
          final leituras = provider.historico.reversed.toList();
          final ultima = leituras.isNotEmpty ? leituras.last : null;

          if (isMobile) {
            return _buildMainContent(ultima, leituras, isMobile);
          } else {
            return Row(
              children: [
                _buildSidebar(ultima, isMobile),
                Expanded(
                  child: _buildMainContent(ultima, leituras, isMobile),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMainContent(dynamic ultima, List<dynamic> leituras, bool isMobile) {
    return Column(
      children: [
        _buildHeader(ultima, isMobile),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : 40.0,
              vertical: isMobile ? 16.0 : 24.0,
            ),
            child: Column(
              children: [
                _buildKPISection(ultima, isMobile), 
                SizedBox(height: isMobile ? 16 : 32),
                Expanded(child: _buildChartContainer(leituras, isMobile)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(dynamic ultima, bool isMobile) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      ),
      child: Column(
        children: [
          if (!isMobile)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("SMAmT\nTELEMETRIA", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          SizedBox(height: isMobile ? 40 : 20),
          
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.grey),
            title: const Text("Voltar ao Hub", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.overview),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Divider(color: Colors.white10),
          ),
          
          _buildMenuItem('Temperatura', Icons.thermostat_outlined, ultima != null ? _getCorTemp(ultima.temperatura) : Colors.grey.shade700, isMobile),
          _buildMenuItem('Umidade', Icons.water_drop_outlined, ultima != null ? _getCorUmid(ultima.umidade) : Colors.grey.shade700, isMobile),
          _buildMenuItem('Ruído', Icons.volume_up_outlined, ultima != null ? _getCorRuido(ultima.ruido) : Colors.grey.shade700, isMobile),
          
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Color(0xFFFF3366)),
            title: const Text("Encerrar Sessão", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String nome, IconData icone, Color corStatus, bool isMobile) {
    bool isSelected = _parametroAtivo == nome;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? corStatus.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? corStatus.withOpacity(0.3) : Colors.transparent),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icone, color: isSelected ? corStatus : Colors.grey.shade600),
        title: Text(nome, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade500, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, letterSpacing: 1)),
        onTap: () {
          setState(() => _parametroAtivo = nome);
          if (isMobile) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildHeader(dynamic ultima, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF09090B),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _headerContents(ultima, isMobile),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _headerContents(ultima, isMobile),
            ),
    );
  }

  List<Widget> _headerContents(dynamic ultima, bool isMobile) {
    return [
      Row(
        children: [
          Icon(Icons.analytics, color: Colors.white, size: isMobile ? 22 : 28),
          const SizedBox(width: 12),
          Text(
            "ANÁLISE: ${_parametroAtivo.toUpperCase()}",
            style: TextStyle(fontSize: isMobile ? 16 : 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
          ),
        ],
      ),
      if (isMobile) const SizedBox(height: 8), 
      if (ultima != null)
        Row(
          children: [
            const Icon(Icons.sensors, color: Color(0xFF00E676), size: 16),
            const SizedBox(width: 8),
            Text(
              "LIVE DATA • ${DateFormat('HH:mm:ss').format(ultima.dataRegistro)}",
              style: TextStyle(color: const Color(0xFF00E676), fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: isMobile ? 12 : 14, letterSpacing: 1),
            ),
          ],
        )
    ];
  }

  Widget _buildKPISection(dynamic ultima, bool isMobile) {
    if (ultima == null) return const SizedBox();
    
    final cards = [
      _buildStatCard("Temperatura", "${ultima.temperatura.toStringAsFixed(1)} °C", Icons.thermostat, _getCorTemp(ultima.temperatura)),
      _buildStatCard("Umidade", "${ultima.umidade.toStringAsFixed(1)} %", Icons.water_drop, _getCorUmid(ultima.umidade)),
      _buildStatCard("Ruído", "${ultima.ruido.toStringAsFixed(1)} dB", Icons.volume_up, _getCorRuido(ultima.ruido)),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cards.map((card) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 180, 
              child: card,
            ),
          )).toList(),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 24),
        Expanded(child: cards[1]),
        const SizedBox(width: 24),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icone, Color corAlerta) {
    bool isSelected = _parametroAtivo == titulo;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _parametroAtivo = titulo),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? corAlerta.withOpacity(0.5) : Colors.white.withOpacity(0.05), 
            width: isSelected ? 2 : 1
          ),
          boxShadow: isSelected ? [BoxShadow(color: corAlerta.withOpacity(0.1), blurRadius: 20, spreadRadius: -5)] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icone, color: isSelected ? corAlerta : Colors.grey.shade600, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(titulo.toUpperCase(), style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, fontFamily: 'monospace')),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer(List<dynamic> leituras, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B), 
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24), 
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: leituras.isEmpty 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : LineChart(_buildIndividualChart(leituras)),
    );
  }

  LineChartData _buildIndividualChart(List<dynamic> leituras) {
    List<FlSpot> spots = [];
    List<Color> gradientColors = [];
    List<double> gradientStops = [];
    double minY = 0;
    double maxY = 100;

    // 1. Alimenta os spots, redefinimos os limites (minY e maxY) e configuramos os gradientes NEON
    if (_parametroAtivo == 'Temperatura') {
      spots = leituras.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.temperatura)).toList();
      minY = 15; maxY = 45; // Escala focada
      gradientColors = [const Color(0xFF00E676), const Color(0xFFFFB020), const Color(0xFFFF3366)];
      gradientStops = [0.0, (27 - minY) / (maxY - minY), (30 - minY) / (maxY - minY)];
    } 
    else if (_parametroAtivo == 'Umidade') {
      spots = leituras.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.umidade)).toList();
      minY = 0; maxY = 100;
      gradientColors = [const Color(0xFFFFB020), const Color(0xFF00E676), const Color(0xFF00E676), const Color(0xFFFFB020)];
      gradientStops = [0.0, 0.3, 0.7, 1.0];
    } 
    else if (_parametroAtivo == 'Ruído') {
      spots = leituras.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.ruido)).toList();
      minY = 0; // CORREÇÃO: O ruído agora começa em zero para mostrar os vales profundos!
      maxY = 110; // Mantemos o limite superior para ruído industrial
      gradientColors = [const Color(0xFF00E676), const Color(0xFFFFB020), const Color(0xFFFF3366)];
      gradientStops = [0.0, (70 - minY) / (maxY - minY), (85 - minY) / (maxY - minY)];
    }

    return LineChartData(
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35, // Curva mais técnica e precisa
          // O Gradiente Neon Dinâmico direto na linha
          gradient: LinearGradient(
            colors: gradientColors,
            stops: gradientStops,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            // Sombraluminosa (Glow) super sutil abaixo da linha
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.15)).toList(),
              stops: gradientStops,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        )
      ],
      // Grades do fundo (Grid) agora são um cinza quase invisível
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.white.withOpacity(0.02), strokeWidth: 1),
      ),
      // Títulos sutilmente integrados
      titlesData: const FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white.withOpacity(0.05))),
    );
  }
}






