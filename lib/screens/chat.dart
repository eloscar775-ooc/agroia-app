import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final String _sid = 'sesion_${Random().nextInt(99999)}';
  final List<Map<String, String>> _msgs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _msgs.add({'rol': 'ia', 'texto': '¡Hola! Soy AgroIA. ¿En qué puedo ayudarte con tus cultivos?'});
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty || _loading) return;
    setState(() { _msgs.add({'rol': 'user', 'texto': t}); _loading = true; });
    _ctrl.clear();
    final prov = context.read<AppProvider>();
    final resp = await ApiService(prov.apiUrl).chat(pregunta: t, cicloId: prov.cicloActivoId, sesionId: _sid);
    if (mounted) setState(() { _msgs.add({'rol': 'ia', 'texto': resp}); _loading = false; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Asistente IA')),
    body: Column(children: [
      Expanded(child: ListView.builder(
        controller: _scroll, padding: const EdgeInsets.all(16),
        itemCount: _msgs.length,
        itemBuilder: (_, i) => Align(
          alignment: _msgs[i]['rol'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _msgs[i]['rol'] == 'user' ? const Color(0xFF2ECC71) : const Color(0xFF1A2A1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_msgs[i]['texto'] ?? '', style: TextStyle(color: _msgs[i]['rol'] == 'user' ? Colors.black : Colors.white)),
          ),
        ),
      )),
      if (_loading) const LinearProgressIndicator(color: Color(0xFF2ECC71)),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Pregunta algo...'))),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFF2ECC71)), onPressed: _send),
        ]),
      ),
    ]),
  );
}
