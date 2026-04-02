import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── PARCELAS ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getParcelas() async {
    final resp = await http.get(Uri.parse('$baseUrl/parcelas/'), headers: _headers);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    throw Exception('Error cargando parcelas: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> crearParcela(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/parcelas/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error creando parcela');
  }

  // ── CICLOS ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> crearCiclo(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/ciclos/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error creando ciclo');
  }

  Future<List<Map<String, dynamic>>> getCiclosPorParcela(int parcelaId) async {
    final resp = await http.get(Uri.parse('$baseUrl/ciclos/parcela/$parcelaId'), headers: _headers);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    throw Exception('Error cargando ciclos');
  }

  // ── APLICACIONES ──────────────────────────────────────────────

  Future<Map<String, dynamic>> registrarAplicacion(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/aplicaciones/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error registrando aplicación');
  }

  Future<List<Map<String, dynamic>>> getAplicaciones(int cicloId) async {
    final resp = await http.get(Uri.parse('$baseUrl/aplicaciones/ciclo/$cicloId'), headers: _headers);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    throw Exception('Error cargando aplicaciones');
  }

  // ── DIAGNÓSTICO POR FOTO ──────────────────────────────────────

  Future<Map<String, dynamic>> diagnosticarFoto(File foto, int cicloId) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/diagnostico/foto/$cicloId'),
    );
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error analizando foto: ${resp.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getHistorialDiagnosticos(int cicloId) async {
    final resp = await http.get(Uri.parse('$baseUrl/diagnostico/ciclo/$cicloId'), headers: _headers);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    return [];
  }

  // ── CHAT IA ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> enviarMensajeChat({
    required String pregunta,
    int? cicloId,
    String? sesionId,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/chat/'),
      headers: _headers,
      body: jsonEncode({
        'pregunta': pregunta,
        'ciclo_id': cicloId,
        'sesion_id': sesionId,
      }),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error en chat IA');
  }

  // ── CLIMA ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getClimaActual() async {
    final resp = await http.get(Uri.parse('$baseUrl/clima/actual'), headers: _headers);
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error cargando clima');
  }

  // ── COSTOS ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCostosCiclo(int cicloId) async {
    final resp = await http.get(Uri.parse('$baseUrl/costos/ciclo/$cicloId'), headers: _headers);
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Error cargando costos');
  }

  Future<List<Map<String, dynamic>>> getAlertas(int cicloId) async {
    final resp = await http.get(Uri.parse('$baseUrl/costos/alertas/$cicloId'), headers: _headers);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return List<Map<String, dynamic>>.from(data['alertas'] ?? []);
    }
    return [];
  }
}
