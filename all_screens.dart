// lib/screens/all_screens.dart
// Dashboard, Parcelas, Diagnostico, Chat, Costos - COMPLETO Y FUNCIONAL

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/ia_service.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const _verde = Color(0xFF2ECC71);
const _verdeOscuro = Color(0xFF1A7A43);
const _bg = Color(0xFF0A0F0D);
const _card = Color(0xFF1A2A1E);
const _card2 = Color(0xFF111A14);
const _texto = Color(0xFFE8F5EC);
const _texto2 = Color(0xFF9DBFA8);
const _rojo = Color(0xFFE74C3C);
const _amarillo = Color(0xFFF0C040);
const _azul = Color(0xFF29B6F6);

String _uid() => '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

Widget _tarjeta({required Widget child, Color? borde}) => Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: _card,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: borde ?? Colors.white.withOpacity(0.08)),
  ),
  child: child,
);

Widget _chip(String texto, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.4))),
  child: Text(texto, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
);

void _snack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? _rojo : _verdeOscuro,
    behavior: SnackBarBehavior.floating,
  ));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final res = prov.resumenDashboard;
    final alertas = res['alertas'] as List<Map<String, String>>;
    final ciclosActivos = prov.ciclos.where((c) => c.rendimientoTonHa == null).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card2,
        title: const Row(children: [
          Text('🌽', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text('AgroIA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _verde)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: _verde), onPressed: prov.cargarTodo),
        ],
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator(color: _verde))
          : RefreshIndicator(
              color: _verde,
              onRefresh: prov.cargarTodo,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Stats principales
                Row(children: [
                  _StatBox('${res['totalParcelas']}', 'Parcelas', Icons.map, _verde),
                  const SizedBox(width: 10),
                  _StatBox('${(res['totalHa'] as double).toStringAsFixed(1)} ha', 'Hectareas', Icons.straighten, _azul),
                  const SizedBox(width: 10),
                  _StatBox('${res['ciclosActivos']}', 'Ciclos\nActivos', Icons.agriculture, _amarillo),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _StatBox('\$${_fmt(res['totalGastos'] as double)}', 'Gastos', Icons.payments, _rojo),
                  const SizedBox(width: 10),
                  _StatBox('\$${_fmt(res['totalIngresos'] as double)}', 'Ingresos', Icons.trending_up, _verde),
                  const SizedBox(width: 10),
                  _StatBox('\$${_fmt(res['ganancia'] as double)}', 'Ganancia', Icons.savings, (res['ganancia'] as double) >= 0 ? _verde : _rojo),
                ]),
                const SizedBox(height: 18),

                // Ciclos activos con estado
                if (ciclosActivos.isNotEmpty) ...[
                  const Text('Cultivos en curso', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _texto)),
                  const SizedBox(height: 8),
                  ...ciclosActivos.map((c) => _CicloCard(ciclo: c)),
                  const SizedBox(height: 14),
                ],

                // Alertas IA
                if (alertas.isNotEmpty) ...[
                  Row(children: [
                    const Text('Alertas y Recomendaciones', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _texto)),
                    const SizedBox(width: 8),
                    _chip('${alertas.length}', _rojo),
                  ]),
                  const SizedBox(height: 8),
                  ...alertas.take(5).map((a) => _AlertaRow(
                    nivel: a['nivel'] ?? 'info',
                    titulo: a['parcela'] ?? '',
                    desc: a['mensaje'] ?? '',
                  )),
                ] else
                  _tarjeta(child: const Column(children: [
                    Icon(Icons.check_circle, color: _verde, size: 36),
                    SizedBox(height: 8),
                    Text('Todo en orden', style: TextStyle(color: _verde, fontWeight: FontWeight.bold)),
                    Text('Agrega parcelas y ciclos para ver recomendaciones', style: TextStyle(color: _texto2, fontSize: 12), textAlign: TextAlign.center),
                  ])),

                const SizedBox(height: 14),

                // Cosechas recientes
                if (prov.cosechas.isNotEmpty) ...[
                  const Text('Ultimas Cosechas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _texto)),
                  const SizedBox(height: 8),
                  ...prov.cosechas.reversed.take(3).map((c) => _tarjeta(child: Row(children: [
                    const Icon(Icons.grain, color: _verde),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.parcela, style: const TextStyle(fontWeight: FontWeight.bold, color: _texto)),
                      Text('${c.rendimientoTonHa} ton/ha | ${c.tipo}', style: const TextStyle(color: _texto2, fontSize: 12)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${_fmt(c.ganancia)}', style: TextStyle(color: c.ganancia >= 0 ? _verde : _rojo, fontWeight: FontWeight.bold)),
                      Text('ganancia', style: const TextStyle(color: _texto2, fontSize: 10)),
                    ]),
                  ]))),
                ],
              ]),
            ),
    );
  }

  String _fmt(double v) => v.abs() >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatBox(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: _texto2)),
    ]),
  ));
}

class _CicloCard extends StatelessWidget {
  final Ciclo ciclo;
  const _CicloCard({required this.ciclo});

  @override
  Widget build(BuildContext context) {
    final pct = (ciclo.diasTranscurridos / 130).clamp(0.0, 1.0);
    return _tarjeta(borde: _verde.withOpacity(0.3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(ciclo.parcela, style: const TextStyle(fontWeight: FontWeight.bold, color: _texto, fontSize: 14))),
        _chip('Dia ${ciclo.diasTranscurridos}', _verde),
      ]),
      const SizedBox(height: 4),
      Text('${ciclo.variedad} | ${ciclo.etapaCultivo}', style: const TextStyle(color: _texto2, fontSize: 12)),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white.withOpacity(0.08), color: _verde, minHeight: 6)),
      const SizedBox(height: 4),
      Text('${(pct * 100).toInt()}% del ciclo completado', style: const TextStyle(fontSize: 10, color: _texto2)),
    ]));
  }
}

class _AlertaRow extends StatelessWidget {
  final String nivel, titulo, desc;
  const _AlertaRow({required this.nivel, required this.titulo, required this.desc});

  @override
  Widget build(BuildContext context) {
    final color = nivel == 'critico' ? _rojo : nivel == 'advertencia' ? _amarillo : _verde;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: color, width: 3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        Text(desc, style: const TextStyle(fontSize: 12, color: _texto2)),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PARCELAS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ParcelasScreen extends StatelessWidget {
  const ParcelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card2,
        title: const Text('Mis Parcelas', style: TextStyle(color: _verde, fontWeight: FontWeight.bold)),
      ),
      body: prov.parcelas.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.map_outlined, size: 64, color: _texto2),
              const SizedBox(height: 16),
              const Text('No tienes parcelas registradas', style: TextStyle(color: _texto2, fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black),
                icon: const Icon(Icons.add), label: const Text('Agregar Parcela'),
                onPressed: () => _mostrarFormParcela(context),
              ),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.parcelas.length,
              itemBuilder: (_, i) => _ParcelaItem(parcela: prov.parcelas[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _verde, foregroundColor: Colors.black,
        icon: const Icon(Icons.add), label: const Text('Nueva Parcela', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _mostrarFormParcela(context),
      ),
    );
  }

  void _mostrarFormParcela(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FormParcela(),
    );
  }
}

class _ParcelaItem extends StatelessWidget {
  final Parcela parcela;
  const _ParcelaItem({required this.parcela});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final ciclo = prov.getCicloParcela(parcela.id);

    return _tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(parcela.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _texto))),
        PopupMenuButton<String>(
          color: _card2,
          icon: const Icon(Icons.more_vert, color: _texto2),
          onSelected: (v) {
            if (v == 'ciclo') _agregarCiclo(context, parcela);
            if (v == 'delete') _confirmarEliminar(context, parcela.id, prov);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'ciclo', child: Text('Iniciar Ciclo', style: TextStyle(color: _texto))),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: _rojo))),
          ],
        ),
      ]),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 4, children: [
        _chip('${parcela.superficieHa} ha', _azul),
        _chip(parcela.tipoSuelo, _amarillo),
        _chip(parcela.tipoCultivo, _verde),
        _chip(parcela.nivelTerreno, _texto2),
      ]),
      if (parcela.altitudMetros != null || parcela.phSuelo != null) ...[
        const SizedBox(height: 6),
        Text('${parcela.altitudMetros != null ? "Alt: ${parcela.altitudMetros!.toInt()}m  " : ""}${parcela.phSuelo != null ? "pH: ${parcela.phSuelo}" : ""}',
            style: const TextStyle(fontSize: 12, color: _texto2)),
      ],
      if (parcela.ubicacion != null) Text('Ubicacion: ${parcela.ubicacion}', style: const TextStyle(fontSize: 12, color: _texto2)),
      if (parcela.observaciones != null) Text(parcela.observaciones!, style: const TextStyle(fontSize: 12, color: _texto2)),
      if (ciclo != null) ...[
        const Divider(color: Colors.white12, height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ciclo activo: ${ciclo.variedad}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _verde)),
            Text('${ciclo.etapaCultivo} | Dia ${ciclo.diasTranscurridos}', style: const TextStyle(fontSize: 11, color: _texto2)),
          ])),
          _chip('${ciclo.diasTranscurridos}d', _verde),
        ]),
        const SizedBox(height: 6),
        ...ciclo.recomendaciones.take(2).map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(children: [
            const Icon(Icons.arrow_right, color: _verde, size: 16),
            Expanded(child: Text(r, style: const TextStyle(fontSize: 11, color: _texto2))),
          ]),
        )),
      ] else ...[
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: _verde, side: const BorderSide(color: _verde)),
          icon: const Icon(Icons.agriculture, size: 16),
          label: const Text('Iniciar Ciclo de Siembra', style: TextStyle(fontSize: 12)),
          onPressed: () => _agregarCiclo(context, parcela),
        )),
      ],
    ]));
  }

  void _confirmarEliminar(BuildContext ctx, String id, AppProvider prov) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: _card,
      title: const Text('Eliminar Parcela', style: TextStyle(color: _rojo)),
      content: const Text('Esta accion no se puede deshacer.', style: TextStyle(color: _texto2)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _rojo),
          onPressed: () { Navigator.pop(ctx); prov.eliminarParcela(id); },
          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _agregarCiclo(BuildContext ctx, Parcela parcela) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormCiclo(parcela: parcela),
    );
  }
}

class _FormParcela extends StatefulWidget {
  const _FormParcela();
  @override
  State<_FormParcela> createState() => _FormParcelaState();
}

class _FormParcelaState extends State<_FormParcela> {
  final _nombre = TextEditingController();
  final _superficie = TextEditingController();
  final _ph = TextEditingController();
  final _altitud = TextEditingController();
  final _ubicacion = TextEditingController();
  final _obs = TextEditingController();
  String _tipoSuelo = 'Arenoso';
  String _tipoCultivo = 'Temporal';
  String _nivel = 'Plano';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        const Text('Nueva Parcela', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _verde)),
        const SizedBox(height: 14),
        _campo(_nombre, 'Nombre de la parcela *', icon: Icons.map),
        _campo(_superficie, 'Superficie (hectareas) *', tipo: TextInputType.number, icon: Icons.straighten),
        _drop('Tipo de suelo', _tipoSuelo, ['Arenoso', 'Arcilloso', 'Franco', 'Limoso', 'Mixto'], (v) => setState(() => _tipoSuelo = v!)),
        _drop('Tipo de cultivo', _tipoCultivo, ['Temporal', 'Riego', 'Humedad'], (v) => setState(() => _tipoCultivo = v!)),
        _drop('Nivel del terreno', _nivel, ['Plano', 'Ligero desnivel', 'Desnivel fuerte', 'Semiplano'], (v) => setState(() => _nivel = v!)),
        _campo(_ph, 'pH del suelo (ej: 6.5)', tipo: TextInputType.number, icon: Icons.science),
        _campo(_altitud, 'Altitud en metros (ej: 1500)', tipo: TextInputType.number, icon: Icons.terrain),
        _campo(_ubicacion, 'Ubicacion / Municipio', icon: Icons.location_on),
        _campo(_obs, 'Observaciones del suelo', icon: Icons.notes, lineas: 2),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: _guardar,
          child: const Text('Guardar Parcela', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        )),
        const SizedBox(height: 20),
      ])),
    );
  }

  void _guardar() {
    if (_nombre.text.isEmpty || _superficie.text.isEmpty) {
      _snack(context, 'Nombre y superficie son obligatorios', error: true);
      return;
    }
    final sup = double.tryParse(_superficie.text);
    if (sup == null || sup <= 0) {
      _snack(context, 'Superficie invalida', error: true);
      return;
    }
    final parcela = Parcela(
      id: _uid(), nombre: _nombre.text.trim(),
      superficieHa: sup, tipoSuelo: _tipoSuelo,
      tipoCultivo: _tipoCultivo, nivelTerreno: _nivel,
      phSuelo: double.tryParse(_ph.text),
      altitudMetros: double.tryParse(_altitud.text),
      ubicacion: _ubicacion.text.isEmpty ? null : _ubicacion.text,
      observaciones: _obs.text.isEmpty ? null : _obs.text,
      creadaEn: DateTime.now(),
    );
    context.read<AppProvider>().agregarParcela(parcela);
    Navigator.pop(context);
    _snack(context, 'Parcela "${parcela.nombre}" guardada');
  }

  Widget _campo(TextEditingController ctrl, String hint, {TextInputType tipo = TextInputType.text, IconData? icon, int lineas = 1}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
      controller: ctrl, keyboardType: tipo, maxLines: lineas,
      style: const TextStyle(color: _texto),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: _texto2, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: _texto2, size: 18) : null,
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));

  Widget _drop(String label, String value, List<String> items, void Function(String?) onChanged) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: DropdownButtonFormField<String>(
      value: value, onChanged: onChanged,
      dropdownColor: _card2,
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: _texto2, fontSize: 13),
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: const TextStyle(color: _texto, fontSize: 14),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    ));
}

class _FormCiclo extends StatefulWidget {
  final Parcela parcela;
  const _FormCiclo({required this.parcela});
  @override
  State<_FormCiclo> createState() => _FormCicloState();
}

class _FormCicloState extends State<_FormCiclo> {
  final _variedad = TextEditingController();
  final _densidad = TextEditingController(text: '65000');
  final _tratamiento = TextEditingController();
  final _obs = TextEditingController();
  DateTime _fechaSiembra = DateTime.now();
  String _tipoMaiz = 'Tardio (>120 dias)';
  String _preparacion = 'Barbecho + Rastreo';
  bool _tratada = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('Nuevo Ciclo - ${widget.parcela.nombre}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _verde)),
        const SizedBox(height: 14),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Fecha de siembra: ${_fechaSiembra.day}/${_fechaSiembra.month}/${_fechaSiembra.year}', style: const TextStyle(color: _texto, fontSize: 13)),
          trailing: const Icon(Icons.calendar_today, color: _verde),
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _fechaSiembra, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => _fechaSiembra = d);
          },
        ),
        _campo(_variedad, 'Variedad de semilla (ej: H-59, P30F35) *'),
        _drop('Tipo de maiz', _tipoMaiz, ['Tardio (>120 dias)', 'Intermedio (100-120 dias)', 'Temprano (<100 dias)'], (v) => setState(() => _tipoMaiz = v!)),
        _campo(_densidad, 'Densidad (plantas/ha)', tipo: TextInputType.number),
        _drop('Preparacion del suelo', _preparacion, ['Barbecho + Rastreo', 'Solo Rastreo', 'Labranza minima', 'Sin labranza'], (v) => setState(() => _preparacion = v!)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Semilla tratada', style: TextStyle(color: _texto, fontSize: 13)),
          value: _tratada, activeColor: _verde,
          onChanged: (v) => setState(() => _tratada = v),
        ),
        if (_tratada) _campo(_tratamiento, 'Tipo de tratamiento (ej: Metalaxil)'),
        _campo(_obs, 'Observaciones', lineas: 2),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: _guardar,
          child: const Text('Iniciar Ciclo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        )),
        const SizedBox(height: 20),
      ])),
    );
  }

  void _guardar() {
    if (_variedad.text.isEmpty) { _snack(context, 'La variedad es obligatoria', error: true); return; }
    final ciclo = Ciclo(
      id: _uid(), parcelaId: widget.parcela.id, parcela: widget.parcela.nombre,
      fechaSiembra: _fechaSiembra, variedad: _variedad.text.trim(),
      tipoMaiz: _tipoMaiz, densidadPlantas: int.tryParse(_densidad.text) ?? 65000,
      semillaTratada: _tratada, tratamientoSemilla: _tratada ? _tratamiento.text : null,
      preparacionSuelo: _preparacion, observaciones: _obs.text.isEmpty ? null : _obs.text,
    );
    context.read<AppProvider>().agregarCiclo(ciclo);
    Navigator.pop(context);
    _snack(context, 'Ciclo iniciado en ${widget.parcela.nombre}');
  }

  Widget _campo(TextEditingController ctrl, String hint, {TextInputType tipo = TextInputType.text, int lineas = 1}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
      controller: ctrl, keyboardType: tipo, maxLines: lineas,
      style: const TextStyle(color: _texto),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: _texto2, fontSize: 13),
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));

  Widget _drop(String label, String value, List<String> items, void Function(String?) onChanged) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: DropdownButtonFormField<String>(
      value: value, onChanged: onChanged, dropdownColor: _card2,
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: _texto2, fontSize: 13),
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: const TextStyle(color: _texto, fontSize: 14),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    ));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIAGNOSTICO
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({super.key});
  @override
  State<DiagnosticoScreen> createState() => _DiagState();
}

class _DiagState extends State<DiagnosticoScreen> {
  final _sintomas = TextEditingController();
  String? _parcelaSeleccionada;
  Map<String, dynamic>? _resultado;

  void _analizar() {
    if (_sintomas.text.trim().isEmpty) {
      _snack(context, 'Describe los sintomas que observas', error: true);
      return;
    }
    final prov = context.read<AppProvider>();
    final res = IAService.analizarDescripcion(_sintomas.text, documentos: prov.documentos);
    setState(() => _resultado = res);

    if (_parcelaSeleccionada != null) {
      final parcela = prov.parcelas.firstWhere((p) => p.id == _parcelaSeleccionada, orElse: () => prov.parcelas.first);
      final diag = Diagnostico(
        id: _uid(), parcelaId: _parcelaSeleccionada!,
        parcela: parcela.nombre, fecha: DateTime.now(),
        problema: res['problema'], nivel: res['nivel'],
        descripcion: res['descripcion'], recomendacion: res['recomendacion'],
      );
      prov.agregarDiagnostico(diag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card2,
        title: const Text('Diagnostico IA', style: TextStyle(color: _verde, fontWeight: FontWeight.bold)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Selector de parcela
        if (prov.parcelas.isNotEmpty)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<String>(
            value: _parcelaSeleccionada,
            hint: const Text('Seleccionar parcela (opcional)', style: TextStyle(color: _texto2)),
            dropdownColor: _card2,
            decoration: InputDecoration(filled: true, fillColor: _card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            style: const TextStyle(color: _texto),
            onChanged: (v) => setState(() => _parcelaSeleccionada = v),
            items: prov.parcelas.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
          )),

        // Input de sintomas
        _tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Describe los sintomas', style: TextStyle(fontWeight: FontWeight.bold, color: _texto, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Ej: hojas con manchas amarillas, bordes quemados, polvo cafe en hojas, insectos en cogollo...', style: TextStyle(color: _texto2, fontSize: 11)),
          const SizedBox(height: 10),
          TextField(
            controller: _sintomas, maxLines: 4,
            style: const TextStyle(color: _texto, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Describe lo que ves en tu cultivo...',
              hintStyle: const TextStyle(color: _texto2),
              filled: true, fillColor: _bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.search), label: const Text('Analizar con IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: _analizar,
          )),
        ])),

        // Resultado
        if (_resultado != null) _ResultadoCard(res: _resultado!),

        // Historial
        if (prov.diagnosticos.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Diagnosticos Anteriores', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _texto)),
          const SizedBox(height: 8),
          ...prov.diagnosticos.reversed.map((d) => _DiagHistItem(diag: d)),
        ],
      ]),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final Map<String, dynamic> res;
  const _ResultadoCard({required this.res});

  @override
  Widget build(BuildContext context) {
    final color = res['nivel'] == 'alto' ? _rojo : res['nivel'] == 'medio' ? _amarillo : _verde;
    return _tarjeta(borde: color, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.biotech, color: color, size: 28),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${res['problema']}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
          Text('Confianza: ${res['confianza']}% | Tipo: ${res['tipo']} | Nivel: ${res['nivel']}', style: const TextStyle(fontSize: 11, color: _texto2)),
        ])),
      ]),
      const Divider(color: Colors.white12, height: 16),
      Text('${res['descripcion']}', style: const TextStyle(fontSize: 13, color: _texto2, height: 1.5)),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Control recomendado:', style: TextStyle(color: _verde, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text('${res['recomendacion']}', style: const TextStyle(color: _texto, fontSize: 13, height: 1.5)),
        if (res['prevencion'] != null) ...[
          const SizedBox(height: 6),
          Text('Prevencion: ${res['prevencion']}', style: const TextStyle(color: _texto2, fontSize: 12, height: 1.4)),
        ],
      ])),
    ]));
  }
}

class _DiagHistItem extends StatelessWidget {
  final Diagnostico diag;
  const _DiagHistItem({required this.diag});

  @override
  Widget build(BuildContext context) {
    final color = diag.nivel == 'alto' ? _rojo : diag.nivel == 'medio' ? _amarillo : _verde;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: color, width: 3))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(diag.problema, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _texto)),
          Text('${diag.parcela} | ${diag.fecha.day}/${diag.fecha.month}/${diag.fecha.year}', style: const TextStyle(fontSize: 11, color: _texto2)),
          Text(diag.recomendacion.split('.').first, style: const TextStyle(fontSize: 11, color: _texto2), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        if (diag.tratado)
          _chip('Tratado', _verde)
        else
          TextButton(
            onPressed: () => context.read<AppProvider>().marcarTratado(diag.id),
            child: const Text('Marcar\ntratado', style: TextStyle(color: _verde, fontSize: 10), textAlign: TextAlign.center),
          ),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAT IA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _msgs = [];
  bool _loading = false;
  late TabController _tabCtrl;
  final _docNombre = TextEditingController();
  final _docContenido = TextEditingController();
  final _feedbackCtrl = TextEditingController();
  final _feedbackResultado = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    final prov = context.read<AppProvider>();
    // Cargar historial
    _msgs.addAll(prov.mensajes);
    if (_msgs.isEmpty) {
      _msgs.add({'rol': 'ia', 'texto': 'Hola! Soy tu asistente agronomo AgroIA. Puedo ayudarte con diagnostico de plagas, recomendaciones de fertilizacion, manejo del cultivo y analisis de tus datos. Preguntame lo que necesites!'});
    }
  }

  Future<void> _enviar() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty || _loading) return;
    setState(() { _msgs.add({'rol': 'user', 'texto': t}); _loading = true; });
    _ctrl.clear();
    _down();

    final prov = context.read<AppProvider>();
    await prov.agregarMensaje('user', t);

    await Future.delayed(const Duration(milliseconds: 600));

    final respuesta = IAService.responderChat(
      t,
      ciclos: prov.ciclos,
      parcelas: prov.parcelas,
      cosechas: prov.cosechas,
      documentos: prov.documentos,
      feedback: prov.feedback,
    );

    await prov.agregarMensaje('ia', respuesta);
    if (mounted) setState(() { _msgs.add({'rol': 'ia', 'texto': respuesta}); _loading = false; });
    _down();
  }

  void _down() => Future.delayed(const Duration(milliseconds: 200), () {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card2,
        title: const Text('Asistente IA', style: TextStyle(color: _verde, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _verde, unselectedLabelColor: _texto2,
          indicatorColor: _verde,
          tabs: const [Tab(text: 'Chat'), Tab(text: 'Documentos'), Tab(text: 'Aprendizaje')],
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        // TAB 1: CHAT
        Column(children: [
          Expanded(child: ListView.builder(
            controller: _scroll, padding: const EdgeInsets.all(16),
            itemCount: _msgs.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _msgs.length) return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 60, child: LinearProgressIndicator(color: _verde))));
              final m = _msgs[i]; final ia = m['rol'] == 'ia';
              return Align(
                alignment: ia ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                  decoration: BoxDecoration(
                    color: ia ? _card : _verdeOscuro,
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14), bottomLeft: Radius.circular(ia ? 4 : 14), bottomRight: Radius.circular(ia ? 14 : 4)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (ia) const Text('AgroIA', style: TextStyle(fontSize: 10, color: _verde, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(m['texto']!, style: const TextStyle(fontSize: 13, color: _texto, height: 1.5)),
                  ]),
                ),
              );
            },
          )),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: _card2, border: Border(top: BorderSide(color: Colors.white12))),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl, style: const TextStyle(color: _texto, fontSize: 14),
                onSubmitted: (_) => _enviar(), maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Pregunta sobre tu cultivo...', hintStyle: const TextStyle(color: _texto2),
                  filled: true, fillColor: _card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(onTap: _enviar, child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: _verde, shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.black, size: 20))),
            ]),
          ),
        ]),

        // TAB 2: DOCUMENTOS
        ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Sube documentos para que la IA aprenda', style: TextStyle(color: _texto, fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('Manuales de fertilizacion, guias de plagas, recomendaciones agronomicas...', style: TextStyle(color: _texto2, fontSize: 12)),
          const SizedBox(height: 14),
          _tarjeta(child: Column(children: [
            TextField(controller: _docNombre, style: const TextStyle(color: _texto),
              decoration: const InputDecoration(hintText: 'Nombre del documento', hintStyle: TextStyle(color: _texto2), filled: true, fillColor: _bg, border: InputBorder.none, contentPadding: EdgeInsets.all(10))),
            const SizedBox(height: 8),
            TextField(controller: _docContenido, maxLines: 6, style: const TextStyle(color: _texto, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Pega aqui el contenido del documento (texto del manual, recomendaciones, etc.)', hintStyle: TextStyle(color: _texto2, fontSize: 12), filled: true, fillColor: _bg, border: InputBorder.none, contentPadding: EdgeInsets.all(10))),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black),
              onPressed: () {
                if (_docNombre.text.isEmpty || _docContenido.text.isEmpty) { _snack(context, 'Nombre y contenido requeridos', error: true); return; }
                prov.agregarDocumento(_docNombre.text, _docContenido.text);
                _docNombre.clear(); _docContenido.clear();
                _snack(context, 'Documento agregado a la base de conocimiento');
              },
              child: const Text('Agregar documento'),
            )),
          ])),
          const SizedBox(height: 8),
          if (prov.documentos.isEmpty)
            const Center(child: Text('No hay documentos cargados', style: TextStyle(color: _texto2)))
          else
            ...prov.documentos.asMap().entries.map((e) => _tarjeta(child: Row(children: [
              const Icon(Icons.description, color: _verde),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: _texto)),
                Text('${(e.value['contenido'] ?? '').length} caracteres', style: const TextStyle(color: _texto2, fontSize: 11)),
              ])),
              IconButton(icon: const Icon(Icons.delete, color: _rojo, size: 20), onPressed: () => prov.eliminarDocumento(e.key)),
            ]))),
        ]),

        // TAB 3: APRENDIZAJE / FEEDBACK
        ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Retroalimentacion para la IA', style: TextStyle(color: _texto, fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('Cuéntame que funcionó y qué no para que aprenda de tu experiencia', style: TextStyle(color: _texto2, fontSize: 12)),
          const SizedBox(height: 14),
          _tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Contexto (ej: fertilizacion en suelo arenoso):', style: TextStyle(color: _texto2, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _feedbackCtrl, style: const TextStyle(color: _texto, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Que practica o situacion describes...', hintStyle: TextStyle(color: _texto2), filled: true, fillColor: _bg, border: InputBorder.none, contentPadding: EdgeInsets.all(10))),
            const SizedBox(height: 8),
            const Text('Resultado obtenido:', style: TextStyle(color: _texto2, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _feedbackResultado, maxLines: 3, style: const TextStyle(color: _texto, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Que resultado obtuviste? Fue bueno o malo?', hintStyle: TextStyle(color: _texto2), filled: true, fillColor: _bg, border: InputBorder.none, contentPadding: EdgeInsets.all(10))),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black),
              onPressed: () {
                if (_feedbackCtrl.text.isEmpty || _feedbackResultado.text.isEmpty) { _snack(context, 'Completa ambos campos', error: true); return; }
                prov.agregarFeedback({'contexto': _feedbackCtrl.text, 'resultado': _feedbackResultado.text, 'fecha': DateTime.now().toIso8601String()});
                _feedbackCtrl.clear(); _feedbackResultado.clear();
                _snack(context, 'Feedback guardado. La IA lo usara en futuras respuestas');
              },
              child: const Text('Guardar retroalimentacion'),
            )),
          ])),
          if (prov.feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Historial de aprendizaje:', style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...prov.feedback.reversed.map((fb) => _tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Contexto: ${fb['contexto']}', style: const TextStyle(color: _verde, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Resultado: ${fb['resultado']}', style: const TextStyle(color: _texto2, fontSize: 12)),
            ]))),
          ],
        ]),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COSTOS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CostosScreen extends StatefulWidget {
  const CostosScreen({super.key});
  @override
  State<CostosScreen> createState() => _CostosState();
}

class _CostosState extends State<CostosScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final total = prov.getTotalGastos();
    final ingresos = prov.totalIngresos;
    final ganancia = prov.totalGanancia;
    final porCategoria = prov.getGastosPorCategoria();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card2,
        title: const Text('Costos y Finanzas', style: TextStyle(color: _verde, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab, labelColor: _verde, unselectedLabelColor: _texto2, indicatorColor: _verde,
          tabs: const [Tab(text: 'Resumen'), Tab(text: 'Gastos'), Tab(text: 'Cosechas')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        // TAB 1: RESUMEN
        ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            _FinBox('\$${_f(total)}', 'Total Gastos', Icons.payments, _rojo),
            const SizedBox(width: 10),
            _FinBox('\$${_f(ingresos)}', 'Total Ingresos', Icons.trending_up, _azul),
            const SizedBox(width: 10),
            _FinBox('\$${_f(ganancia)}', 'Ganancia Neta', Icons.savings, ganancia >= 0 ? _verde : _rojo),
          ]),
          const SizedBox(height: 16),
          if (ganancia != 0) _tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ROI General', style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(total > 0 ? '${((ganancia / total) * 100).toStringAsFixed(1)}% retorno sobre la inversion' : 'Sin gastos registrados', style: TextStyle(color: ganancia >= 0 ? _verde : _rojo, fontSize: 18, fontWeight: FontWeight.bold)),
          ])),
          if (porCategoria.isNotEmpty) ...[
            const Text('Gastos por Categoria', style: TextStyle(color: _texto, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...porCategoria.entries.map((e) {
              final pct = total > 0 ? e.value / total : 0.0;
              return Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(e.key, style: const TextStyle(color: _texto, fontSize: 13)),
                  Text('\$${_f(e.value)}', style: const TextStyle(color: _verde, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white.withOpacity(0.08), color: _verde, minHeight: 6)),
                Text('${(pct * 100).toStringAsFixed(1)}%', style: const TextStyle(color: _texto2, fontSize: 10)),
              ]));
            }),
          ] else
            _tarjeta(child: const Center(child: Text('No hay gastos registrados', style: TextStyle(color: _texto2)))),
        ]),

        // TAB 2: GASTOS
        Column(children: [
          Expanded(child: prov.gastos.isEmpty
              ? const Center(child: Text('No hay gastos registrados.\nToca + para agregar.', style: TextStyle(color: _texto2), textAlign: TextAlign.center))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.gastos.length,
                  itemBuilder: (_, i) {
                    final g = prov.gastos[prov.gastos.length - 1 - i];
                    return _tarjeta(child: Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: _categoriaColor(g.categoria).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Icon(_categoriaIcon(g.categoria), color: _categoriaColor(g.categoria), size: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(g.concepto, style: const TextStyle(fontWeight: FontWeight.bold, color: _texto, fontSize: 13)),
                        Text('${g.categoria} | ${g.parcela} | ${g.fecha.day}/${g.fecha.month}/${g.fecha.year}', style: const TextStyle(color: _texto2, fontSize: 11)),
                        if (g.notas != null) Text(g.notas!, style: const TextStyle(color: _texto2, fontSize: 11)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('\$${_f(g.monto)}', style: const TextStyle(fontWeight: FontWeight.bold, color: _rojo, fontSize: 14)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: _texto2, size: 18), onPressed: () => prov.eliminarGasto(g.id), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ]),
                    ]));
                  },
                )),
          Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.add), label: const Text('Registrar Gasto', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _formGasto(context),
          ))),
        ]),

        // TAB 3: COSECHAS
        Column(children: [
          Expanded(child: prov.cosechas.isEmpty
              ? const Center(child: Text('No hay cosechas registradas.\nToca + para agregar.', style: TextStyle(color: _texto2), textAlign: TextAlign.center))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.cosechas.length,
                  itemBuilder: (_, i) {
                    final c = prov.cosechas[prov.cosechas.length - 1 - i];
                    return _tarjeta(borde: c.ganancia >= 0 ? _verde.withOpacity(0.3) : _rojo.withOpacity(0.3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(c.parcela, style: const TextStyle(fontWeight: FontWeight.bold, color: _texto, fontSize: 14)),
                        _chip(c.tipo, _azul),
                      ]),
                      const SizedBox(height: 6),
                      Text('${c.fecha.day}/${c.fecha.month}/${c.fecha.year} | ${c.superficieHa} ha | ${c.rendimientoTonHa} ton/ha', style: const TextStyle(color: _texto2, fontSize: 12)),
                      const Divider(color: Colors.white12, height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _MiniStat('Produccion', '${c.produccionTotal.toStringAsFixed(1)} ton'),
                        _MiniStat('Ingreso', '\$${_f(c.ingresoTotal)}'),
                        _MiniStat('Costo', '\$${_f(c.costoTotal)}'),
                        _MiniStat('Ganancia', '\$${_f(c.ganancia)}', color: c.ganancia >= 0 ? _verde : _rojo),
                      ]),
                      if (c.roi != 0) Padding(padding: const EdgeInsets.only(top: 6), child: Text('ROI: ${c.roi.toStringAsFixed(1)}%', style: TextStyle(color: c.roi >= 0 ? _verde : _rojo, fontWeight: FontWeight.bold, fontSize: 12))),
                      if (c.observaciones != null) Text(c.observaciones!, style: const TextStyle(color: _texto2, fontSize: 11)),
                    ]));
                  },
                )),
          Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _verdeOscuro, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.agriculture), label: const Text('Registrar Cosecha', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _formCosecha(context),
          ))),
        ]),
      ]),
    );
  }

  String _f(double v) => v.abs() >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);

  Color _categoriaColor(String cat) {
    switch (cat) {
      case 'Fertilizante': return _verde;
      case 'Semilla': return _azul;
      case 'Maquinaria': return _amarillo;
      case 'Transporte': return Colors.orange;
      case 'Herbicida': return Colors.purple;
      case 'Insecticida': return _rojo;
      case 'Mano de obra': return Colors.teal;
      default: return _texto2;
    }
  }

  IconData _categoriaIcon(String cat) {
    switch (cat) {
      case 'Fertilizante': return Icons.science;
      case 'Semilla': return Icons.grass;
      case 'Maquinaria': return Icons.agriculture;
      case 'Transporte': return Icons.local_shipping;
      case 'Herbicida': return Icons.eco;
      case 'Insecticida': return Icons.bug_report;
      case 'Mano de obra': return Icons.people;
      default: return Icons.attach_money;
    }
  }

  void _formGasto(BuildContext ctx) {
    final prov = ctx.read<AppProvider>();
    final concepto = TextEditingController();
    final monto = TextEditingController();
    final notas = TextEditingController();
    String categoria = 'Fertilizante';
    String? parcelaId;
    String parcelaNombre = 'General';

    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx2) => StatefulBuilder(builder: (ctx3, ss) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx3).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Registrar Gasto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _verde)),
          const SizedBox(height: 12),
          if (prov.parcelas.isNotEmpty)
            DropdownButtonFormField<String>(
              value: parcelaId, hint: const Text('Parcela (opcional)', style: TextStyle(color: _texto2)),
              dropdownColor: _card2, style: const TextStyle(color: _texto),
              decoration: InputDecoration(filled: true, fillColor: _bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              onChanged: (v) { ss(() { parcelaId = v; parcelaNombre = prov.parcelas.firstWhere((p) => p.id == v).nombre; }); },
              items: prov.parcelas.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
            ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: categoria,
            dropdownColor: _card2, style: const TextStyle(color: _texto),
            decoration: InputDecoration(labelText: 'Categoria', labelStyle: const TextStyle(color: _texto2), filled: true, fillColor: _bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            onChanged: (v) => ss(() => categoria = v!),
            items: ['Fertilizante', 'Semilla', 'Maquinaria', 'Transporte', 'Herbicida', 'Insecticida', 'Mano de obra', 'Riego', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
          const SizedBox(height: 10),
          _input(concepto, 'Concepto (ej: Urea 46% 150kg)', ctx3),
          _input(monto, 'Monto (\$)', ctx3, tipo: TextInputType.number),
          _input(notas, 'Notas (opcional)', ctx3),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              final m = double.tryParse(monto.text);
              if (concepto.text.isEmpty || m == null) { _snack(ctx3, 'Concepto y monto son requeridos', error: true); return; }
              prov.agregarGasto(Gasto(id: _uid(), parcelaId: parcelaId ?? 'general', parcela: parcelaNombre, categoria: categoria, concepto: concepto.text, monto: m, fecha: DateTime.now(), notas: notas.text.isEmpty ? null : notas.text));
              Navigator.pop(ctx3);
              _snack(ctx, 'Gasto registrado');
            },
            child: const Text('Guardar Gasto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          )),
          const SizedBox(height: 20),
        ])),
      )),
    );
  }

  void _formCosecha(BuildContext ctx) {
    final prov = ctx.read<AppProvider>();
    final rendimiento = TextEditingController();
    final precio = TextEditingController();
    final obs = TextEditingController();
    String tipo = 'Maiz grano';
    String? parcelaId;
    String parcelaNombre = '';
    double superficieHa = 1.0;

    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx2) => StatefulBuilder(builder: (ctx3, ss) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx3).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Registrar Cosecha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _verde)),
          const SizedBox(height: 12),
          if (prov.parcelas.isNotEmpty)
            DropdownButtonFormField<String>(
              value: parcelaId, hint: const Text('Selecciona la parcela *', style: TextStyle(color: _texto2)),
              dropdownColor: _card2, style: const TextStyle(color: _texto),
              decoration: InputDecoration(filled: true, fillColor: _bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              onChanged: (v) { ss(() { parcelaId = v; final p = prov.parcelas.firstWhere((p) => p.id == v); parcelaNombre = p.nombre; superficieHa = p.superficieHa; }); },
              items: prov.parcelas.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
            ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: tipo, dropdownColor: _card2, style: const TextStyle(color: _texto),
            decoration: InputDecoration(labelText: 'Tipo de cosecha', labelStyle: const TextStyle(color: _texto2), filled: true, fillColor: _bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            onChanged: (v) => ss(() => tipo = v!),
            items: ['Maiz grano', 'Silo forrajero', 'Rastrojo', 'Elote'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
          const SizedBox(height: 10),
          _input(rendimiento, 'Rendimiento (ton/ha) *', ctx3, tipo: TextInputType.number),
          _input(precio, 'Precio de venta (\$/ton) *', ctx3, tipo: TextInputType.number),
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('Costos totales registrados: \$${_f(prov.getTotalGastos(parcelaId: parcelaId))}', style: const TextStyle(color: _texto2, fontSize: 13))),
          _input(obs, 'Observaciones de la cosecha', ctx3),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _verdeOscuro, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              if (parcelaId == null) { _snack(ctx3, 'Selecciona la parcela', error: true); return; }
              final r = double.tryParse(rendimiento.text);
              final p = double.tryParse(precio.text);
              if (r == null || p == null) { _snack(ctx3, 'Rendimiento y precio son requeridos', error: true); return; }
              final cosecha = Cosecha(
                id: _uid(), parcelaId: parcelaId!, parcela: parcelaNombre,
                fecha: DateTime.now(), tipo: tipo, rendimientoTonHa: r,
                superficieHa: superficieHa, precioVentaTon: p,
                costoTotal: prov.getTotalGastos(parcelaId: parcelaId),
                observaciones: obs.text.isEmpty ? null : obs.text,
              );
              prov.agregarCosecha(cosecha);
              Navigator.pop(ctx3);
              _snack(ctx, 'Cosecha registrada. Ganancia: \$${_f(cosecha.ganancia)}');
            },
            child: const Text('Guardar Cosecha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          )),
          const SizedBox(height: 20),
        ])),
      )),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, BuildContext ctx, {TextInputType tipo = TextInputType.text}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
      controller: ctrl, keyboardType: tipo,
      style: const TextStyle(color: _texto, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: _texto2, fontSize: 12),
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));
}

class _FinBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _FinBox(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: _texto2), textAlign: TextAlign.center),
    ]),
  ));
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _MiniStat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: const TextStyle(color: _texto2, fontSize: 10)),
    Text(value, style: TextStyle(color: color ?? _texto, fontWeight: FontWeight.bold, fontSize: 12)),
  ]);
}
