// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _kParcelas = 'parcelas_v2';
  static const _kCiclos = 'ciclos_v2';
  static const _kGastos = 'gastos_v2';
  static const _kCosechas = 'cosechas_v2';
  static const _kDiagnosticos = 'diagnosticos_v2';
  static const _kMensajes = 'mensajes_v2';
  static const _kDocumentos = 'documentos_v2';
  static const _kFeedback = 'feedback_v2';

  // PARCELAS
  Future<List<Parcela>> getParcelas() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kParcelas);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Parcela.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveParcela(Parcela parcela) async {
    final list = await getParcelas();
    final idx = list.indexWhere((x) => x.id == parcela.id);
    if (idx >= 0) list[idx] = parcela; else list.add(parcela);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kParcelas, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  Future<void> deleteParcela(String id) async {
    final list = await getParcelas();
    list.removeWhere((x) => x.id == id);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kParcelas, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // CICLOS
  Future<List<Ciclo>> getCiclos() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kCiclos);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Ciclo.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCiclo(Ciclo ciclo) async {
    final list = await getCiclos();
    final idx = list.indexWhere((x) => x.id == ciclo.id);
    if (idx >= 0) list[idx] = ciclo; else list.add(ciclo);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCiclos, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // GASTOS
  Future<List<Gasto>> getGastos() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kGastos);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Gasto.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveGasto(Gasto gasto) async {
    final list = await getGastos();
    list.add(gasto);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kGastos, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  Future<void> deleteGasto(String id) async {
    final list = await getGastos();
    list.removeWhere((x) => x.id == id);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kGastos, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // COSECHAS
  Future<List<Cosecha>> getCosechas() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kCosechas);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Cosecha.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCosecha(Cosecha cosecha) async {
    final list = await getCosechas();
    list.add(cosecha);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCosechas, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // DIAGNOSTICOS
  Future<List<Diagnostico>> getDiagnosticos() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kDiagnosticos);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Diagnostico.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveDiagnostico(Diagnostico d) async {
    final list = await getDiagnosticos();
    final idx = list.indexWhere((x) => x.id == d.id);
    if (idx >= 0) list[idx] = d; else list.add(d);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDiagnosticos, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // MENSAJES CHAT
  Future<List<Map<String, String>>> getMensajes() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kMensajes);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  Future<void> addMensaje(String rol, String texto) async {
    final list = await getMensajes();
    list.add({'rol': rol, 'texto': texto, 'fecha': DateTime.now().toIso8601String()});
    // Mantener solo los ultimos 50 mensajes
    if (list.length > 50) list.removeRange(0, list.length - 50);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kMensajes, jsonEncode(list));
  }

  // DOCUMENTOS / CONOCIMIENTO
  Future<List<Map<String, String>>> getDocumentos() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kDocumentos);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  Future<void> addDocumento(String nombre, String contenido) async {
    final list = await getDocumentos();
    list.add({'nombre': nombre, 'contenido': contenido, 'fecha': DateTime.now().toIso8601String()});
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDocumentos, jsonEncode(list));
  }

  Future<void> deleteDocumento(int index) async {
    final list = await getDocumentos();
    if (index >= 0 && index < list.length) list.removeAt(index);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDocumentos, jsonEncode(list));
  }

  // FEEDBACK IA
  Future<List<Map<String, dynamic>>> getFeedback() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kFeedback);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  Future<void> addFeedback(Map<String, dynamic> fb) async {
    final list = await getFeedback();
    list.add(fb);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kFeedback, jsonEncode(list));
  }
}
