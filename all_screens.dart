// ═══════════════════════════════════════════════════════════════════
// screens/chat_screen.dart
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

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
      'texto': '👋 Hola! Soy AgroIA, tu asistente agrónomo.\n\n'
          'Tengo acceso a tus parcelas, historial de aplicaciones y documentos técnicos.\n\n'
          '¿En qué te puedo ayudar hoy?',
    });
  }

  Future<void> _enviar() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;

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
      setState(() {
        _mensajes.add({'rol': 'ia', 'texto': resp['respuesta'] ?? 'Sin respuesta'});
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _mensajes.add({'rol': 'ia', 'texto': '⚠️ Error de conexión. Verifica la URL del servidor en Configuración.'});
        _cargando = false;
      });
    }
    _scrollAbajo();
  }

  void _scrollAbajo() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Text('🤖 ', style: TextStyle(fontSize: 20)),
          Text('Asistente IA', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text('● En línea', style: TextStyle(fontSize: 11, color: Color(0xFF2ECC71))),
          )
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
                        width: 40,
                        child: LinearProgressIndicator(color: Color(0xFF2ECC71)),
                      ),
                    ),
                  );
                }
                final msg = _mensajes[i];
                final esIA = msg['rol'] == 'ia';
                return Align(
                  alignment: esIA ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    decoration: BoxDecoration(
                      color: esIA ? const Color(0xFF1A2A1E) : const Color(0xFF1A5C32),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(esIA ? 4 : 14),
                        bottomRight: Radius.circular(esIA ? 14 : 4),
                      ),
                      border: esIA ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (esIA)
                          const Text('🌽 AgroIA', style: TextStyle(
                            fontSize: 10, color: Color(0xFF2ECC71), fontWeight: FontWeight.bold,
                          )),
                        const SizedBox(height: 2),
                        Text(msg['texto']!, style: const TextStyle(fontSize: 13.5, color: Color(0xFFE8F5EC), height: 1.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _enviar,
                  child: Container(
                    width: 44, height: 44,
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

// ═══════════════════════════════════════════════════════════════════
// screens/diagnostico_screen.dart
// ═══════════════════════════════════════════════════════════════════

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({super.key});
  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  bool _analizando = false;
  Map<String, dynamic>? _resultado;

  Future<void> _tomarFoto(bool camara) async {
    // image_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📷 Seleccionando imagen...')),
    );
    // En la app real: usar ImagePicker y llamar a api.diagnosticarFoto()
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _resultado = {
        'problema_detectado': 'Gusano cogollero (Spodoptera frugiperda)',
        'confianza_pct': 87,
        'nivel_dano': 'medio',
        'descripcion': 'Se observan perforaciones en el cogollo y presencia de aserrín característico de larvas de gusano cogollero en estadio 3.',
        'recomendacion_inmediata': 'Aplicar insecticida sistémico en las próximas 24-48 horas.',
        'recomendacion_producto': 'Clorpirifos 48% EC — 1.5 L/ha + Cipermetrina 20% — 0.4 L/ha en mezcla',
        'hora_aplicacion': 'tarde-noche',
        'urgencia': 'inmediata',
        'fuente': 'Manual CIMMYT de Plagas 2022',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Diagnóstico IA', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BOTONES FOTO
          Row(
            children: [
              Expanded(child: _BtnFoto(
                icon: Icons.camera_alt, label: 'Tomar Foto',
                onTap: () => _tomarFoto(true),
              )),
              const SizedBox(width: 12),
              Expanded(child: _BtnFoto(
                icon: Icons.photo_library, label: 'Galería',
                onTap: () => _tomarFoto(false),
              )),
            ],
          ),
          const SizedBox(height: 16),

          // INSTRUCCIONES
          if (_resultado == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  const Text('📷', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('Toma una foto de tu cultivo', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC),
                  )),
                  const SizedBox(height: 8),
                  Text(
                    'La IA analizará la imagen y detectará:\n• Plagas (gusano cogollero, pulgón, trips...)\n• Enfermedades (roya, carbón, tizón...)\n• Deficiencias nutritivas (N, P, K, Zn...)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.6),
                  ),
                ],
              ),
            ),
          ],

          // RESULTADO IA
          if (_resultado != null) _ResultadoIA(resultado: _resultado!),

          const SizedBox(height: 24),
          const Text('📁 Diagnósticos Anteriores', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC),
          )),
          const SizedBox(height: 10),
          _HistorialItem(titulo: 'Gusano cogollero', nivel: 'medio', fecha: '12 Jun', tratado: true),
          _HistorialItem(titulo: 'Deficiencia Nitrógeno', nivel: 'bajo', fecha: '05 Jun', tratado: true),
          _HistorialItem(titulo: 'Planta sana', nivel: 'ninguno', fecha: '01 Jun', tratado: false),
        ],
      ),
    );
  }
}

class _BtnFoto extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BtnFoto({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A7A43), Color(0xFF2ECC71)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    ),
  );
}

class _ResultadoIA extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const _ResultadoIA({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final nivel = resultado['nivel_dano'] ?? 'bajo';
    final urgencia = resultado['urgencia'] ?? 'monitorear';
    final color = urgencia == 'inmediata' ? const Color(0xFFE74C3C)
        : urgencia == 'esta_semana' ? const Color(0xFFF0C040)
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
          Row(children: [
            const Text('🐛', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(resultado['problema_detectado'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
              Text('Confianza: ${resultado['confianza_pct']}% • Daño: $nivel',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
              child: Text(urgencia.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 12),
          Text(resultado['descripcion'] ?? '', style: const TextStyle(fontSize: 12.5, color: Color(0xFF9DBFA8), height: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0A0F0D), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💊 Recomendación:', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Text(resultado['recomendacion_producto'] ?? '', style: const TextStyle(color: Color(0xFFE8F5EC), fontSize: 13)),
              const SizedBox(height: 4),
              Text('🕐 Hora ideal: ${resultado['hora_aplicacion']}', style: const TextStyle(color: Color(0xFF9DBFA8), fontSize: 12)),
              Text('📚 Fuente: ${resultado['fuente']}', style: const TextStyle(color: Color(0xFF9DBFA8), fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _HistorialItem extends StatelessWidget {
  final String titulo, nivel, fecha;
  final bool tratado;
  const _HistorialItem({required this.titulo, required this.nivel, required this.fecha, required this.tratado});

  @override
  Widget build(BuildContext context) {
    final color = nivel == 'alto' ? const Color(0xFFE74C3C)
        : nivel == 'medio' ? const Color(0xFFF0C040)
        : const Color(0xFF2ECC71);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
          Text('$fecha • Nivel: $nivel', style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
        ])),
        if (tratado) Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFF2ECC71).withOpacity(0.2), borderRadius: BorderRadius.circular(999)),
          child: const Text('✓ Tratado', style: TextStyle(fontSize: 10, color: Color(0xFF2ECC71))),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// screens/parcelas_screen.dart
// ═══════════════════════════════════════════════════════════════════

class ParcelasScreen extends StatelessWidget {
  const ParcelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parcelas = context.watch<AppProvider>().parcelas;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Parcelas', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Color(0xFF2ECC71)), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parcelas.length,
        itemBuilder: (_, i) => _ParcelaCard(parcela: parcelas[i]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Parcela', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {},
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
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('🌽 ${parcela['nombre']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
                  if (ciclo != null) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
                    ),
                    child: Text('Día ${ciclo['dias']}', style: const TextStyle(fontSize: 12, color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 14, runSpacing: 4, children: [
                  _InfoChip('📐 ${parcela['superficie_ha']} ha'),
                  _InfoChip('🌧️ ${parcela['tipo_cultivo']}'),
                  _InfoChip('🟤 ${parcela['tipo_suelo']}'),
                  if (ciclo != null) _InfoChip('🌱 ${ciclo['variedad']}'),
                ]),
              ],
            ),
          ),

          // ACCIONES
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1F3226))),
            ),
            child: Row(
              children: [
                _AccionBtn(Icons.agriculture, 'Aplicación', onTap: () {}),
                _AccionBtn(Icons.water_drop, 'Lluvia/Riego', onTap: () {}),
                _AccionBtn(Icons.bar_chart, 'Resultados', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9DBFA8)));
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
      label: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// screens/costos_screen.dart
// ═══════════════════════════════════════════════════════════════════

class CostosScreen extends StatelessWidget {
  const CostosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Costos', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // RESUMEN
          Row(children: [
            _CostoStat(valor: '\$34,200', label: 'Costo total', icon: '💰'),
            const SizedBox(width: 10),
            _CostoStat(valor: '\$52,800', label: 'Ingreso est.', icon: '📦'),
            const SizedBox(width: 10),
            _CostoStat(valor: '\$18,600', label: 'Ganancia', icon: '📈'),
          ]),
          const SizedBox(height: 20),

          // DESGLOSE
          const Text('📊 Desglose por categoría', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
          const SizedBox(height: 10),
          _CostoBar(categoria: '🌱 Semilla + Prep.', valor: 8400, total: 34200, color: Color(0xFF29B6F6)),
          _CostoBar(categoria: '💊 Fertilizantes', valor: 18600, total: 34200, color: Color(0xFF2ECC71)),
          _CostoBar(categoria: '🐛 Agroquímicos', valor: 7200, total: 34200, color: Color(0xFFE74C3C)),
          const SizedBox(height: 20),

          // TABLA
          const Text('📋 Detalle de gastos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
          const SizedBox(height: 10),
          _GastoItem(concepto: 'Barbecho + rastreo', parcela: 'La Loma', monto: 3600),
          _GastoItem(concepto: 'Semilla H-59', parcela: 'La Loma', monto: 5040),
          _GastoItem(concepto: 'Urea 46% — 1ª aplic.', parcela: 'El Bajo', monto: 6825),
          _GastoItem(concepto: 'DAP 18-46-0', parcela: 'El Bajo', monto: 2240),
          _GastoItem(concepto: 'Atrazina 80%', parcela: 'La Loma', monto: 1350),
          _GastoItem(concepto: 'Clorpirifos 48%', parcela: 'La Cañada', monto: 1140),
        ],
      ),
    );
  }
}

class _CostoStat extends StatelessWidget {
  final String valor, label, icon;
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
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9DBFA8)), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _CostoBar extends StatelessWidget {
  final String categoria;
  final int valor, total;
  final Color color;
  const _CostoBar({required this.categoria, required this.valor, required this.total, required this.color});
  @override
  Widget build(BuildContext context) {
    final pct = valor / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(categoria, style: const TextStyle(fontSize: 12, color: Color(0xFFE8F5EC))),
          Text('\$$valor', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white.withOpacity(0.08), color: color, minHeight: 6),
        ),
      ]),
    );
  }
}

class _GastoItem extends StatelessWidget {
  final String concepto, parcela;
  final int monto;
  const _GastoItem({required this.concepto, required this.parcela, required this.monto});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A1E),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(concepto, style: const TextStyle(fontSize: 13, color: Color(0xFFE8F5EC))),
        Text(parcela, style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
      ])),
      Text('\$$monto', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
    ]),
  );
}
