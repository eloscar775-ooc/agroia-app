import 'package:flutter/material.dart';

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({super.key});
  @override
  State<DiagnosticoScreen> createState() => _DiagState();
}

class _DiagState extends State<DiagnosticoScreen> {
  bool _loading = false;
  Map<String, dynamic>? _res;

  Future<void> _analizar() async {
    setState(() { _loading = true; _res = null; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _loading = false;
      _res = {
        'problema': 'Gusano cogollero (Spodoptera frugiperda)',
        'confianza': 87,
        'nivel': 'medio',
        'descripcion': 'Perforaciones en el cogollo y presencia de aserrin caracteristico de larvas en estadio 3.',
        'producto': 'Clorpirifos 48% EC 1.5 L/ha + Cipermetrina 20% 0.4 L/ha',
        'hora': 'tarde-noche',
        'fuente': 'Manual CIMMYT 2022',
      };
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Diagnostico IA', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A7A43), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          icon: const Icon(Icons.camera_alt), label: const Text('Tomar Foto'), onPressed: _analizar,
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF162019), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xFF2ECC71))),
          icon: const Icon(Icons.photo_library), label: const Text('Galeria'), onPressed: _analizar,
        )),
      ]),
      const SizedBox(height: 16),
      if (_loading)
        const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Color(0xFF2ECC71)))),
      if (!_loading && _res == null)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A2A1E), borderRadius: BorderRadius.circular(12)),
          child: const Column(children: [
            Icon(Icons.camera_alt_outlined, size: 54, color: Color(0xFF2ECC71)),
            SizedBox(height: 12),
            Text('Toma una foto de tu cultivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
            SizedBox(height: 8),
            Text('La IA detectara plagas, enfermedades y deficiencias nutritivas.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF9DBFA8), height: 1.6)),
          ]),
        ),
      if (_res != null) _ResultCard(res: _res!),
      const SizedBox(height: 20),
      const Text('Diagnosticos Anteriores', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
      const SizedBox(height: 8),
      _HistItem(titulo: 'Gusano cogollero', nivel: 'medio', fecha: '12 Jun', tratado: true),
      _HistItem(titulo: 'Deficiencia Nitrogeno', nivel: 'bajo', fecha: '05 Jun', tratado: true),
      _HistItem(titulo: 'Planta sana', nivel: 'ninguno', fecha: '01 Jun', tratado: false),
    ]),
  );
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> res;
  const _ResultCard({required this.res});

  @override
  Widget build(BuildContext context) {
    final color = res['nivel'] == 'alto' ? const Color(0xFFE74C3C) : res['nivel'] == 'medio' ? const Color(0xFFF0C040) : const Color(0xFF2ECC71);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2A1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5), width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bug_report, size: 32, color: Color(0xFFE74C3C)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${res['problema']}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
            Text('Confianza: ${res['confianza']}% | Dano: ${res['nivel']}', style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
          ])),
        ]),
        const SizedBox(height: 10),
        Text('${res['descripcion']}', style: const TextStyle(fontSize: 12, color: Color(0xFF9DBFA8), height: 1.5)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF0A0F0D), borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Recomendacion:', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Text('${res['producto']}', style: const TextStyle(color: Color(0xFFE8F5EC), fontSize: 13)),
            Text('Hora: ${res['hora']}', style: const TextStyle(color: Color(0xFF9DBFA8), fontSize: 12)),
            Text('Fuente: ${res['fuente']}', style: const TextStyle(color: Color(0xFF9DBFA8), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

class _HistItem extends StatelessWidget {
  final String titulo, nivel, fecha;
  final bool tratado;
  const _HistItem({required this.titulo, required this.nivel, required this.fecha, required this.tratado});

  @override
  Widget build(BuildContext context) {
    final color = nivel == 'alto' ? const Color(0xFFE74C3C) : nivel == 'medio' ? const Color(0xFFF0C040) : const Color(0xFF2ECC71);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A2A1E), borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: color, width: 3))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
          Text('$fecha | $nivel', style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
        ])),
        if (tratado)
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF2ECC71).withOpacity(0.2), borderRadius: BorderRadius.circular(999)),
            child: const Text('Tratado', style: TextStyle(fontSize: 10, color: Color(0xFF2ECC71)))),
      ]),
    );
  }
}
