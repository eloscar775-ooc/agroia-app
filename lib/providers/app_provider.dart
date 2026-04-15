import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  String _url = 'http://10.0.2.2:8000/api';
  bool _loading = false;
  List<Map<String, dynamic>> _parcelas = [];
  Map<String, dynamic>? _clima;
  int? _cicloId;

  String get apiUrl => _url;
  bool get isLoading => _loading;
  List<Map<String, dynamic>> get parcelas => _parcelas;
  Map<String, dynamic>? get climaActual => _clima;
  int? get cicloActivoId => _cicloId;

  AppProvider() { _init(); }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    _url = p.getString('api_url') ?? 'http://10.0.2.2:8000/api';
    await cargarDatos();
  }

  Future<void> cargarDatos() async {
    _loading = true;
    notifyListeners();
    final api = ApiService(_url);
    final result = await api.getParcelas();
    _parcelas = result.isEmpty ? _demo() : result;
    _clima = await api.getClimaActual();
    if (_parcelas.isNotEmpty) {
      final c = _parcelas.first['ciclo_activo'];
      if (c != null) _cicloId = c['id'] as int?;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> setApiUrl(String url) async {
    _url = url;
    final p = await SharedPreferences.getInstance();
    await p.setString('api_url', url);
    await cargarDatos();
  }

  List<Map<String, dynamic>> _demo() => [
    {'id': 1, 'nombre': 'La Loma', 'superficie_ha': 3.0, 'tipo_cultivo': 'temporal', 'tipo_suelo': 'arenoso',
     'ciclo_activo': {'id': 1, 'variedad': 'H-59', 'tipo_maiz': 'tardio', 'dias': 42}},
    {'id': 2, 'nombre': 'El Bajo', 'superficie_ha': 3.5, 'tipo_cultivo': 'riego', 'tipo_suelo': 'arcilloso',
     'ciclo_activo': {'id': 2, 'variedad': 'P30F35', 'tipo_maiz': 'temprano', 'dias': 18}},
  ];
}
