// lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Parcela> parcelas = [];
  List<Ciclo> ciclos = [];
  List<Gasto> gastos = [];
  List<Cosecha> cosechas = [];
  List<Diagnostico> diagnosticos = [];
  List<Map<String, String>> mensajes = [];
  List<Map<String, String>> documentos = [];
  List<Map<String, dynamic>> feedback = [];
  bool isLoading = false;

  AppProvider() { cargarTodo(); }

  Future<void> cargarTodo() async {
    isLoading = true;
    notifyListeners();
    parcelas = await _storage.getParcelas();
    ciclos = await _storage.getCiclos();
    gastos = await _storage.getGastos();
    cosechas = await _storage.getCosechas();
    diagnosticos = await _storage.getDiagnosticos();
    mensajes = await _storage.getMensajes();
    documentos = await _storage.getDocumentos();
    feedback = await _storage.getFeedback();
    isLoading = false;
    notifyListeners();
  }

  // PARCELAS
  Future<void> agregarParcela(Parcela p) async {
    await _storage.saveParcela(p);
    parcelas = await _storage.getParcelas();
    notifyListeners();
  }

  Future<void> eliminarParcela(String id) async {
    await _storage.deleteParcela(id);
    parcelas = await _storage.getParcelas();
    notifyListeners();
  }

  // CICLOS
  Future<void> agregarCiclo(Ciclo c) async {
    await _storage.saveCiclo(c);
    ciclos = await _storage.getCiclos();
    notifyListeners();
  }

  Ciclo? getCicloParcela(String parcelaId) {
    try {
      return ciclos.lastWhere((c) => c.parcelaId == parcelaId);
    } catch (_) { return null; }
  }

  // GASTOS
  Future<void> agregarGasto(Gasto g) async {
    await _storage.saveGasto(g);
    gastos = await _storage.getGastos();
    notifyListeners();
  }

  Future<void> eliminarGasto(String id) async {
    await _storage.deleteGasto(id);
    gastos = await _storage.getGastos();
    notifyListeners();
  }

  double getTotalGastos({String? parcelaId}) {
    final lista = parcelaId != null ? gastos.where((g) => g.parcelaId == parcelaId) : gastos;
    return lista.fold(0.0, (s, g) => s + g.monto);
  }

  Map<String, double> getGastosPorCategoria({String? parcelaId}) {
    final lista = parcelaId != null ? gastos.where((g) => g.parcelaId == parcelaId) : gastos;
    final Map<String, double> result = {};
    for (final g in lista) {
      result[g.categoria] = (result[g.categoria] ?? 0) + g.monto;
    }
    return result;
  }

  // COSECHAS
  Future<void> agregarCosecha(Cosecha c) async {
    await _storage.saveCosecha(c);
    cosechas = await _storage.getCosechas();
    notifyListeners();
  }

  double get totalIngresos => cosechas.fold(0.0, (s, c) => s + c.ingresoTotal);
  double get totalGanancia => cosechas.fold(0.0, (s, c) => s + c.ganancia);

  // DIAGNOSTICOS
  Future<void> agregarDiagnostico(Diagnostico d) async {
    await _storage.saveDiagnostico(d);
    diagnosticos = await _storage.getDiagnosticos();
    notifyListeners();
  }

  Future<void> marcarTratado(String id) async {
    final idx = diagnosticos.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      diagnosticos[idx].tratado = true;
      await _storage.saveDiagnostico(diagnosticos[idx]);
      notifyListeners();
    }
  }

  // CHAT
  Future<void> agregarMensaje(String rol, String texto) async {
    await _storage.addMensaje(rol, texto);
    mensajes = await _storage.getMensajes();
    notifyListeners();
  }

  // DOCUMENTOS
  Future<void> agregarDocumento(String nombre, String contenido) async {
    await _storage.addDocumento(nombre, contenido);
    documentos = await _storage.getDocumentos();
    notifyListeners();
  }

  Future<void> eliminarDocumento(int index) async {
    await _storage.deleteDocumento(index);
    documentos = await _storage.getDocumentos();
    notifyListeners();
  }

  // FEEDBACK
  Future<void> agregarFeedback(Map<String, dynamic> fb) async {
    await _storage.addFeedback(fb);
    feedback = await _storage.getFeedback();
    notifyListeners();
  }

  // RESUMEN DASHBOARD
  Map<String, dynamic> get resumenDashboard {
    final ciclosActivos = ciclos.where((c) => c.rendimientoTonHa == null).toList();
    final alertas = <Map<String, String>>[];
    for (final c in ciclosActivos) {
      for (final r in c.recomendaciones) {
        alertas.add({'parcela': c.parcela, 'mensaje': r, 'nivel': 'advertencia'});
      }
      if (c.diasTranscurridos >= 35 && c.diasTranscurridos <= 55) {
        alertas.add({'parcela': c.parcela, 'mensaje': 'Riesgo alto de gusano cogollero', 'nivel': 'critico'});
      }
    }
    return {
      'totalParcelas': parcelas.length,
      'totalHa': parcelas.fold(0.0, (s, p) => s + p.superficieHa),
      'ciclosActivos': ciclosActivos.length,
      'totalGastos': getTotalGastos(),
      'totalIngresos': totalIngresos,
      'ganancia': totalGanancia,
      'alertas': alertas,
    };
  }
}
