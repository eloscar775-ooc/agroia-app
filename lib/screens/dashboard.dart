import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final parcelas = prov.parcelas;
    final clima = prov.climaActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroIA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF2ECC71)), onPressed: prov.cargarDatos),
          IconButton(icon: const Icon(Icons.settings, color: Color(0xFF9DBFA8)), onPressed: () => _showConfig(context, prov)),
        ],
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : RefreshIndicator(
              color: const Color(0xFF2ECC71),
              onRefresh: prov.cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    _StatCard(value: '${parcelas.length}', label: 'Parcelas', icon: Icons.agriculture, color: const Color(0xFF2ECC71)),
                    const SizedBox(width: 12),
                    _StatCard(
                      value: '${parcelas.fold<double>(0.0, (s, x) => s + ((x['superficie_ha'] as num?)?.toDouble() ?? 0.0)).toStringAsFixed(1)} ha',
                      label: 'Hectareas', icon: Icons.straighten, color: const Color(0xFF29B6F6),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  if (clima != null) _ClimaCard(clima: clima),
                  const SizedBox(height: 14),
                  _AlertaBanner(),
                  const SizedBox(height: 20),
                  const Text('Mis Parcelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
                  const SizedBox(height: 10),
                  for (final p in parcelas) _ParcelaCard(parcela: p),
                  const SizedBox(height: 20),
                  const Text('Alertas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
                  const SizedBox(height: 8),
                  _AlertaRow(nivel: 'critico', titulo: 'Riesgo: Gusano cogollero', desc: 'La Loma dia 42. Temperatura favorable.'),
                  _AlertaRow(nivel: 'advertencia', titulo: 'Fertilizar El Bajo', desc: 'Dia 18 - Ventana optima 2da fertilizacion.'),
                  _AlertaRow(nivel: 'ok', titulo: 'Riego completado', desc: 'El Bajo - Siguiente riego en 4 dias.'),
                ],
              ),
            ),
    );
  }

  void _showConfig(BuildContext ctx, AppProvider prov) {
    final ctrl = TextEditingController(text: prov.apiUrl);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A1E),
        title: const Text('Configuracion', style: TextStyle(color: Color(0xFF2ECC71))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('URL del servidor:', style: TextStyle(color: Color(0xFF9DBFA8), fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl, style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'http://10.0.2.2:8000/api',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true, fillColor: const Color(0xFF0A0F0D),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Emulador: http://10.0.2.2:8000/api\nCelular: http://TU_IP:8000/api',
              style: TextStyle(color: Color(0xFF9DBFA8), fontSize: 11)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71)),
            onPressed: () { prov.setApiUrl(ctrl.text); Navigator.pop(ctx); },
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
      ]),
    ),
  );
}

class _ClimaCard extends StatelessWidget {
  final Map<String, dynamic> clima;
  const _ClimaCard({required this.clima});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A1E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Clima Actual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Sensor(value: '${clima['temperatura_c'] ?? '--'}C', label: 'Temp', color: const Color(0xFFFF7043)),
        _Sensor(value: '${clima['humedad_pct'] ?? '--'}%', label: 'Humedad', color: const Color(0xFF29B6F6)),
        _Sensor(value: '${clima['lluvia_mm'] ?? 0}mm', label: 'Lluvia', color: const Color(0xFF7C4DFF)),
        _Sensor(value: '${clima['viento_kmh'] ?? '--'}km/h', label: 'Viento', color: const Color(0xFF2ECC71)),
      ]),
    ]),
  );
}

class _Sensor extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Sensor({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9DBFA8))),
  ]);
}

class _AlertaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A1E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
    ),
    child: Row(children: [
      const Icon(Icons.psychology, color: Color(0xFF2ECC71), size: 26),
      const SizedBox(width: 10),
      const Expanded(child: Text('El Bajo dia 18: momento optimo para 1a fertilizacion nitrogenada.', style: TextStyle(fontSize: 13, color: Color(0xFFE8F5EC)))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF2ECC71), borderRadius: BorderRadius.circular(8)),
        child: const Text('Ver', style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    ]),
  );
}

class _AlertaRow extends StatelessWidget {
  final String nivel, titulo, desc;
  const _AlertaRow({required this.nivel, required this.titulo, required this.desc});

  @override
  Widget build(BuildContext context) {
    final color = nivel == 'critico' ? const Color(0xFFE74C3C) : nivel == 'advertencia' ? const Color(0xFFF0C040) : const Color(0xFF2ECC71);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
      ]),
    );
  }
}

class _ParcelaCard extends StatelessWidget {
  final Map<String, dynamic> parcela;
  const _ParcelaCard({required this.parcela});

  @override
  Widget build(BuildContext context) {
    final ciclo = parcela['ciclo_activo'] as Map<String, dynamic>?;
    final dias = (ciclo?['dias'] as num?)?.toInt() ?? 0;
    final pct = (dias / 120).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${parcela['nombre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFE8F5EC)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
            ),
            child: Text('Dia $dias', style: const TextStyle(fontSize: 11, color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 6),
        Text('${parcela['superficie_ha']} ha | ${parcela['tipo_cultivo']} | ${parcela['tipo_suelo']} | ${ciclo?['variedad'] ?? ''}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9DBFA8))),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white.withOpacity(0.08), color: const Color(0xFF2ECC71), minHeight: 5)),
        const SizedBox(height: 3),
        Text('${(pct * 100).toInt()}% del ciclo', style: const TextStyle(fontSize: 10, color: Color(0xFF9DBFA8))),
      ]),
    );
  }
}
