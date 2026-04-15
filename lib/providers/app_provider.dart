import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  // URL del backend — CAMBIA ESTO a tu IP o dominio de Railway/Render
  static const String _defaultApiUrl = 'http://10.0.2.2:8000/api';

  String _apiUrl = _defaultApiUrl;
  bool _isLoading = false;
  List<Map<String, dynamic>> _parcelas = [];
  List<Map<String, dynamic>> _alertas = [];
  Map<String, dynamic>? _climaActual;
  int? _cicloActivoId;

  String get apiUrl => _apiUrl;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get parcelas => _parcelas;
  List<Map<String, dynamic>> get alertas => _alertas;
  Map<String, dynamic>? get climaActual => _climaActual;
  int? get cicloActivoId => _cicloActivoId;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiUrl = prefs.getString('api_url') ?? _defaultApiUrl;
    await cargarDatos();
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    notifyListeners();
    try {
      final api = ApiService(_apiUrl);
      _parcelas = await api.getParcelas();
      _climaActual = await api.getClimaActual();
      // Cargar alertas del primer ciclo activo
      if (_parcelas.isNotEmpty) {
        final primerCiclo = _parcelas.first['ciclo_activo'];
        if (primerCiclo != null) {
          _cicloActivoId = primerCiclo['id'];
        }
      }
    } catch (e) {
      // Error de conexión — usar datos demo
      _parcelas = _parcelasDemoData();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setApiUrl(String url) async {
    _apiUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', url);
    await cargarDatos();
  }

  List<Map<String, dynamic>> _parcelasDemoData() => [
    {
      'id': 1,
      'nombre': 'La Loma',
      'superficie_ha': 3.0,
      'tipo_cultivo': 'temporal',
      'tipo_suelo': 'arenoso',
      'ciclo_activo': {
        'id': 1,
        'variedad': 'H-59',
        'tipo_maiz': 'tardio',
        'dias': 42,
        'estado': 'en_curso'
      }
    },
    {
      'id': 2,
      'nombre': 'El Bajo',
      'superficie_ha': 3.5,
      'tipo_cultivo': 'riego',
      'tipo_suelo': 'arcilloso',
      'ciclo_activo': {
        'id': 2,
        'variedad': 'P30F35',
        'tipo_maiz': 'temprano',
        'dias': 18,
        'estado': 'en_curso'
      }
    },
  ];
}
