import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/alerta_card.dart';
import '../widgets/clima_widget.dart';

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final parcelas = provider.parcelas;
    final clima = provider.climaActual;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AgroIA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2ECC71),
              ),
            ),
            Text(
              'Temporada 2025',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2ECC71)),
            onPressed: () => provider.cargarDatos(),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF9DBFA8)),
            onPressed: () => _mostrarConfig(context, provider),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
            )
          : RefreshIndicator(
              color: const Color(0xFF2ECC71),
              onRefresh: provider.cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: 'Campo',
                          value: '${parcelas.length}',
                          label: 'Parcelas',
                          color: const Color(0xFF2ECC71),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: 'Area',
                          value:
                              '${parcelas.fold<double>(0, (s, p) => s + (p['superficie_ha'] ?? 0)).toStringAsFixed(1)} ha',
                          label: 'Total',
                          color: const Color(0xFF29B6F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Clima
                  if (clima != null) ClimaWidget(clima: clima),
                  const SizedBox(height: 16),

                  // Alerta IA
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2A1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2ECC71).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.psychology,
                          color: Color(0xFF2ECC71),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Parcela "El Bajo" esta en dia 18. Momento optimo para 1a fertilizacion nitrogenada.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE8F5EC),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Ver',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Parcelas
                  const Text(
                    'Mis Parcelas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8F5EC),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...parcelas.map((p) => _ParcelaCard(parcela: p)),
                  const SizedBox(height: 20),

                  // Alertas
                  const Text(
                    'Alertas Recientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8F5EC),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const AlertaCard(
                    nivel: 'critico',
                    icon: 'Plaga',
                    titulo: 'Riesgo: Gusano cogollero',
                    descripcion:
                        'Parcela La Loma - Dia 42. Temperatura favorable para plaga.',
                  ),
                  const AlertaCard(
                    nivel: 'advertencia',
                    icon: 'Tiempo',
                    titulo: 'Fertilizar El Bajo',
                    descripcion:
                        'Dia 18 - Ventana optima para 2da fertilizacion de nitrogeno.',
                  ),
                  const AlertaCard(
                    nivel: 'ok',
                    icon: 'Agua',
                    titulo: 'Riego completado',
                    descripcion:
                        'El Bajo - Ultimo riego hace 2 dias. Siguiente en 4 dias.',
                  ),
                ],
              ),
            ),
    );
  }

  void _mostrarConfig(BuildContext context, AppProvider provider) {
    final ctrl = TextEditingController(text: provider.apiUrl);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A1E),
        title: const Text(
          'Configuracion',
          style: TextStyle(color: Color(0xFF2ECC71)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'URL del servidor:',
              style: TextStyle(color: Color(0xFF9DBFA8), fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'http://192.168.1.100:8000/api',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF0A0F0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'En emulador: http://10.0.2.2:8000/api\nEn celular: http://TU_IP:8000/api',
              style: TextStyle(color: Color(0xFF9DBFA8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
            ),
            onPressed: () {
              provider.setApiUrl(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcelaCard extends StatelessWidget {
  final Map<String, dynamic> parcela;
  const _ParcelaCard({required this.parcela});

  @override
  Widget build(BuildContext context) {
    final ciclo = parcela['ciclo_activo'];
    final dias = ciclo?['dias'] ?? 0;
    final pct = (dias / 120).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  parcela['nombre'] ?? 'Parcela',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFE8F5EC),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF2ECC71).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  'Dia $dias',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${parcela['superficie_ha']} ha  |  ${parcela['tipo_cultivo']}  |  ${parcela['tipo_suelo']}  |  ${ciclo?['variedad'] ?? ''}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9DBFA8)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: const Color(0xFF2ECC71),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).toInt()}% del ciclo',
            style: const TextStyle(fontSize: 10, color: Color(0xFF9DBFA8)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PARCELAS
// ═══════════════════════════════════════════════════════════════

class ParcelasScreen extends StatelessWidget {
  const ParcelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parcelas = context.watch<AppProvider>().parcelas;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Parcelas',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parcelas.length,
        itemBuilder: (_, i) => _ParcelaDetalle(parcela: parcelas[i]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva Parcela',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {},
      ),
    );
  }
}

class _ParcelaDetalle extends StatelessWidget {
  final Map<String, dynamic> parcela;
  const _ParcelaDetalle({required this.parcela});

  @override
  Widget build(BuildContext context) {
    final ciclo = parcela['ciclo_activo'];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      parcela['nombre'] ?? 'Parcela',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8F5EC),
                      ),
                    ),
                    if (ciclo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF2ECC71).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'Dia ${ciclo['dias']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${parcela['superficie_ha']} ha  |  ${parcela['tipo_cultivo']}  |  ${parcela['tipo_suelo']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9DBFA8),
                  ),
                ),
                if (ciclo != null)
                  Text(
                    'Semilla: ${ciclo['variedad']}  |  Tipo: ${ciclo['tipo_maiz']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9DBFA8),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1F3226))),
            ),
            child: Row(
              children: [
                _AccionBtn(
                  Icons.agriculture,
                  'Aplicacion',
                  onTap: () {},
                ),
                _AccionBtn(
                  Icons.water_drop,
                  'Lluvia/Riego',
                  onTap: () {},
                ),
                _AccionBtn(
                  Icons.bar_chart,
                  'Resultados',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AccionBtn(this.icon, this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: const Color(0xFF2ECC71)),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8)),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// DIAGNOSTICO
// ═══════════════════════════════════════════════════════════════

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({super.key});

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoState();
}

class _DiagnosticoState extends State<DiagnosticoScreen> {
  bool _analizando = false;
  Map<String, dynamic>? _resultado;

  Future<void> _simularDiagnostico() async {
    setState(() {
      _analizando = true;
      _resultado = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analizando = false;
      _resultado = {
        'problema': 'Gusano cogollero (Spodoptera frugiperda)',
        'confianza': 87,
        'nivel': 'medio',
        'descripcion':
            'Se observan perforaciones en el cogollo y presencia de aserrin caracteristico de larvas en estadio 3.',
        'producto': 'Clorpirifos 48% EC - 1.5 L/ha + Cipermetrina 20% - 0.4 L/ha',
        'hora': 'tarde-noche',
        'fuente': 'Manual CIMMYT de Plagas 2022',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnostico IA',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7A43),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  onPressed: _simularDiagnostico,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162019),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF2ECC71)),
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                  onPressed: _simularDiagnostico,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_analizando)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF2ECC71)),
                  SizedBox(height: 14),
                  Text(
                    'Analizando imagen con IA...',
                    style: TextStyle(color: Color(0xFF9DBFA8)),
                  ),
                ],
              ),
            ),

          if (!_analizando && _resultado == null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 54,
                    color: Color(0xFF2ECC71),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toma una foto de tu cultivo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8F5EC),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La IA detectara:\n- Plagas (gusano cogollero, pulgon, trips)\n- Enfermedades (roya, carbon, tizon)\n- Deficiencias (N, P, K, Zn)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          if (_resultado != null) ...[
            _ResultadoWidget(resultado: _resultado!),
            const SizedBox(height: 20),
          ],

          const Text(
            'Diagnosticos Anteriores',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE8F5EC),
            ),
          ),
          const SizedBox(height: 10),
          _HistItem('Gusano cogollero', 'medio', '12 Jun', true),
          _HistItem('Deficiencia Nitrogeno', 'bajo', '05 Jun', true),
          _HistItem('Planta sana', 'ninguno', '01 Jun', false),
        ],
      ),
    );
  }
}

class _ResultadoWidget extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const _ResultadoWidget({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final nivel = resultado['nivel'] ?? 'bajo';
    final color = nivel == 'alto'
        ? const Color(0xFFE74C3C)
        : nivel == 'medio'
        ? const Color(0xFFF0C040)
        : const Color(0xFF2ECC71);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, size: 32, color: Color(0xFFE74C3C)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resultado['problema'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Confianza: ${resultado['confianza']}%  |  Dano: $nivel',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9DBFA8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            resultado['descripcion'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9DBFA8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F0D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recomendacion:',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  resultado['producto'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFFE8F5EC),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hora ideal: ${resultado['hora']}',
                  style: const TextStyle(
                    color: Color(0xFF9DBFA8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Fuente: ${resultado['fuente']}',
                  style: const TextStyle(
                    color: Color(0xFF9DBFA8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistItem extends StatelessWidget {
  final String titulo, nivel, fecha;
  final bool tratado;
  const _HistItem(this.titulo, this.nivel, this.fecha, this.tratado);

  @override
  Widget build(BuildContext context) {
    final color = nivel == 'alto'
        ? const Color(0xFFE74C3C)
        : nivel == 'medio'
        ? const Color(0xFFF0C040)
        : const Color(0xFF2ECC71);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8F5EC),
                  ),
                ),
                Text(
                  '$fecha  |  Nivel: $nivel',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9DBFA8),
                  ),
                ),
              ],
            ),
          ),
          if (tratado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Tratado',
                style: TextStyle(fontSize: 10, color: Color(0xFF2ECC71)),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CHAT IA
// ═══════════════════════════════════════════════════════════════

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _sesionId = 'sesion_${Random().nextInt(99999)}';
  final List<Map<String, String>> _mensajes = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _mensajes.add({
      'rol': 'ia',
      'texto':
          'Hola! Soy AgroIA, tu asistente agronomo.\n\nTengo acceso a tus parcelas, historial de aplicaciones y documentos tecnicos.\n\nEn que te puedo ayudar hoy?',
    });
  }

  Future<void> _enviar() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty || _cargando) return;

    setState(() {
      _mensajes.add({'rol': 'user', 'texto': texto});
      _cargando = true;
    });
    _ctrl.clear();
    _scrollAbajo();

    try {
      final provider = context.read<AppProvider>();
      final api = ApiService(provider.apiUrl);
      final resp = await api.enviarMensajeChat(
        pregunta: texto,
        cicloId: provider.cicloActivoId,
        sesionId: _sesionId,
      );
      if (mounted) {
        setState(() {
          _mensajes.add({
            'rol': 'ia',
            'texto': resp['respuesta'] ?? 'Sin respuesta del servidor',
          });
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensajes.add({
            'rol': 'ia',
            'texto':
                'Error de conexion. Verifica la URL del servidor en Configuracion (icono engranaje en la pantalla de inicio).',
          });
          _cargando = false;
        });
      }
    }
    _scrollAbajo();
  }

  void _scrollAbajo() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asistente IA',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'En linea',
              style: TextStyle(fontSize: 11, color: Color(0xFF2ECC71)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_cargando ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _mensajes.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 50,
                        child: LinearProgressIndicator(
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                    ),
                  );
                }
                final msg = _mensajes[i];
                final esIA = msg['rol'] == 'ia';
                return Align(
                  alignment:
                      esIA ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: esIA
                          ? const Color(0xFF1A2A1E)
                          : const Color(0xFF1A5C32),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(esIA ? 4 : 14),
                        bottomRight: Radius.circular(esIA ? 14 : 4),
                      ),
                      border: esIA
                          ? Border.all(
                              color: Colors.white.withOpacity(0.08),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (esIA)
                          const Text(
                            'AgroIA',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2ECC71),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          msg['texto']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE8F5EC),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF111A14),
              border: Border(top: BorderSide(color: Color(0xFF1F3226))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: (_) => _enviar(),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF1A2A1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _enviar,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// COSTOS
// ═══════════════════════════════════════════════════════════════

class CostosScreen extends StatelessWidget {
  const CostosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control de Costos',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _CostoStat(valor: '\$34,200', label: 'Costo total', icon: Icons.payments),
              const SizedBox(width: 10),
              _CostoStat(valor: '\$52,800', label: 'Ingreso est.', icon: Icons.inventory),
              const SizedBox(width: 10),
              _CostoStat(valor: '\$18,600', label: 'Ganancia', icon: Icons.trending_up),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Desglose por categoria',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE8F5EC),
            ),
          ),
          const SizedBox(height: 10),
          _CostoBar(
            categoria: 'Semilla + Preparacion',
            valor: 8400,
            total: 34200,
            color: const Color(0xFF29B6F6),
          ),
          _CostoBar(
            categoria: 'Fertilizantes',
            valor: 18600,
            total: 34200,
            color: const Color(0xFF2ECC71),
          ),
          _CostoBar(
            categoria: 'Agroquimicos',
            valor: 7200,
            total: 34200,
            color: const Color(0xFFE74C3C),
          ),
          const SizedBox(height: 20),
          const Text(
            'Detalle de gastos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE8F5EC),
            ),
          ),
          const SizedBox(height: 10),
          _GastoItem('Barbecho + rastreo', 'La Loma', 3600),
          _GastoItem('Semilla H-59', 'La Loma', 5040),
          _GastoItem('Urea 46% - 1a aplicacion', 'El Bajo', 6825),
          _GastoItem('DAP 18-46-0', 'El Bajo', 2240),
          _GastoItem('Atrazina 80%', 'La Loma', 1350),
          _GastoItem('Clorpirifos 48%', 'La Canada', 1140),
        ],
      ),
    );
  }
}

class _CostoStat extends StatelessWidget {
  final String valor, label;
  final IconData icon;
  const _CostoStat({required this.valor, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2ECC71), size: 22),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2ECC71),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9DBFA8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _CostoBar extends StatelessWidget {
  final String categoria;
  final int valor, total;
  final Color color;
  const _CostoBar({
    required this.categoria,
    required this.valor,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = valor / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoria,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE8F5EC)),
              ),
              Text(
                '\$$valor',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _GastoItem extends StatelessWidget {
  final String concepto, parcela;
  final int monto;
  const _GastoItem(this.concepto, this.parcela, this.monto);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A1E),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                concepto,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFE8F5EC),
                ),
              ),
              Text(
                parcela,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9DBFA8),
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$$monto',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2ECC71),
          ),
        ),
      ],
    ),
  );
}
