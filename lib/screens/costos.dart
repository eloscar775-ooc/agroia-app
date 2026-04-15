import 'package:flutter/material.dart';

class CostosScreen extends StatelessWidget {
  const CostosScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Costos', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        _Stat(valor: '\$34,200', label: 'Costo total', icon: Icons.payments),
        const SizedBox(width: 10),
        _Stat(valor: '\$52,800', label: 'Ingreso est.', icon: Icons.inventory),
        const SizedBox(width: 10),
        _Stat(valor: '\$18,600', label: 'Ganancia', icon: Icons.trending_up),
      ]),
      const SizedBox(height: 20),
      const Text('Desglose', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
      const SizedBox(height: 10),
      _Bar(cat: 'Semilla + Prep.', val: 8400, tot: 34200, color: const Color(0xFF29B6F6)),
      _Bar(cat: 'Fertilizantes', val: 18600, tot: 34200, color: const Color(0xFF2ECC71)),
      _Bar(cat: 'Agroquimicos', val: 7200, tot: 34200, color: const Color(0xFFE74C3C)),
      const SizedBox(height: 20),
      const Text('Detalle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
      const SizedBox(height: 10),
      _Item(c: 'Barbecho + rastreo', p: 'La Loma', m: 3600),
      _Item(c: 'Semilla H-59', p: 'La Loma', m: 5040),
      _Item(c: 'Urea 46% 1a aplic.', p: 'El Bajo', m: 6825),
      _Item(c: 'DAP 18-46-0', p: 'El Bajo', m: 2240),
      _Item(c: 'Atrazina 80%', p: 'La Loma', m: 1350),
      _Item(c: 'Clorpirifos 48%', p: 'La Canada', m: 1140),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String valor, label;
  final IconData icon;
  const _Stat({required this.valor, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFF1A2A1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))),
    child: Column(children: [
      Icon(icon, color: const Color(0xFF2ECC71), size: 22),
      const SizedBox(height: 4),
      Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9DBFA8)), textAlign: TextAlign.center),
    ]),
  ));
}

class _Bar extends StatelessWidget {
  final String cat;
  final int val, tot;
  final Color color;
  const _Bar({required this.cat, required this.val, required this.tot, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(cat, style: const TextStyle(fontSize: 12, color: Color(0xFFE8F5EC))),
        Text('\$$val', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(value: val / tot, backgroundColor: Colors.white.withOpacity(0.08), color: color, minHeight: 6)),
    ]),
  );
}

class _Item extends StatelessWidget {
  final String c, p;
  final int m;
  const _Item({required this.c, required this.p, required this.m});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFF1A2A1E), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c, style: const TextStyle(fontSize: 13, color: Color(0xFFE8F5EC))),
        Text(p, style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
      ])),
      Text('\$$m', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
    ]),
  );
}
