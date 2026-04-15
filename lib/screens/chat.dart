import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatState();
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
    _msgs.add({'rol': 'ia', 'texto': 'Hola! Soy AgroIA. Tengo acceso a tus parcelas, historial y documentos tecnicos. En que te puedo ayudar?'});
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty || _loading) return;
    setState(() { _msgs.add({'rol': 'user', 'texto': t}); _loading = true; });
    _ctrl.clear();
    _scrollDown();
    final prov = context.read<AppProvider>();
    final resp = await ApiService(prov.apiUrl).chat(pregunta: t, cicloId: prov.cicloActivoId, sesionId: _sid);
    if (mounted) setState(() { _msgs.add({'rol': 'ia', 'texto': resp}); _loading = false; });
    _scrollDown();
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 200), () {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Asistente IA', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
      actions: [
        Container(margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF2ECC71).withOpacity(0.2), borderRadius: BorderRadius.circular(999)),
          child: const Text('En linea', style: TextStyle(fontSize: 11, color: Color(0xFF2ECC71)))),
      ],
    ),
    body: Column(children: [
      Expanded(child: ListView.builder(
        controller: _scroll, padding: const EdgeInsets.all(16),
        itemCount: _msgs.length + (_loading ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == _msgs.length) return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 50, child: LinearProgressIndicator(color: Color(0xFF2ECC71)))));
          final m = _msgs[i];
          final isIA = m['rol'] == 'ia';
          return Align(
            alignment: isIA ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
              decoration: BoxDecoration(
                color: isIA ? const Color(0xFF1A2A1E) : const Color(0xFF1A5C32),
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14), bottomLeft: Radius.circular(isIA ? 4 : 14), bottomRight: Radius.circular(isIA ? 14 : 4)),
                border: isIA ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (isIA) const Text('AgroIA', style: TextStyle(fontSize: 10, color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(m['texto']!, style: const TextStyle(fontSize: 13, color: Color(0xFFE8F5EC), height: 1.5)),
              ]),
            ),
          );
        },
      )),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Color(0xFF111A14), border: Border(top: BorderSide(color: Color(0xFF1F3226)))),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _ctrl, style: const TextStyle(color: Colors.white, fontSize: 14),
            onSubmitted: (_) => _send(), maxLines: null,
            decoration: InputDecoration(
              hintText: 'Escribe tu pregunta...', hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true, fillColor: const Color(0xFF1A2A1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )),
          const SizedBox(width: 8),
          GestureDetector(onTap: _send, child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.black, size: 20))),
        ]),
      ),
    ]),
  );
}
