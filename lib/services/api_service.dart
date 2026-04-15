import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);
  Map<String, String> get _h => {'Content-Type': 'application/json'};

  Future<List<Map<String, dynamic>>> getParcelas() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/parcelas/'), headers: _h).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> getClimaActual() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/clima/actual'), headers: _h).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  Future<String> chat({required String pregunta, int? cicloId, String? sesionId}) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/chat/'), headers: _h,
        body: jsonEncode({'pregunta': pregunta, 'ciclo_id': cicloId, 'sesion_id': sesionId}),
      ).timeout(const Duration(seconds: 30));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        return data['respuesta']?.toString() ?? 'Sin respuesta';
      }
    } catch (_) {}
    return 'Error de conexion. Configura la URL en Ajustes (icono engranaje).';
  }
}
