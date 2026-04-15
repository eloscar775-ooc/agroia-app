import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ParcelasScreen extends StatelessWidget {
  const ParcelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parcelas = context.watch<AppProvider>().parcelas;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Parcelas', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parcelas.length,
        itemBuilder: (_, i) {
          final p = parcelas[i];
          final ciclo = p['ciclo_activo'] as Map<String, dynamic>?;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['nombre']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE8F5EC))),
              const SizedBox(height: 6),
              Text('${p['superficie_ha']} ha | ${p['tipo_cultivo']} | ${p['tipo_suelo']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9DBFA8))),
              if (ciclo != null)
                Text('Semilla: ${ciclo['variedad']} | Tipo: ${ciclo['tipo_maiz']} | Dia: ${ciclo['dias']}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9DBFA8))),
              const SizedBox(height: 10),
              Row(children: [
                _Btn(icon: Icons.agriculture, label: 'Aplicacion', onTap: () {}),
                _Btn(icon: Icons.water_drop, label: 'Riego', onTap: () {}),
                _Btn(icon: Icons.bar_chart, label: 'Resultados', onTap: () {}),
              ]),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Parcela', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {},
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: const Color(0xFF2ECC71)),
      label: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9DBFA8))),
    ),
  );
}
