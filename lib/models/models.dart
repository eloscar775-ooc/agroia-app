// lib/models/models.dart
class Parcela {
  final String id;
  final String nombre;
  final double superficieHa;
  final String tipoSuelo;
  final String tipoCultivo;
  final String nivelTerreno;
  final double? phSuelo;
  final double? altitudMetros;
  final String? ubicacion;
  final String? observaciones;
  final DateTime creadaEn;

  Parcela({
    required this.id,
    required this.nombre,
    required this.superficieHa,
    required this.tipoSuelo,
    required this.tipoCultivo,
    required this.nivelTerreno,
    this.phSuelo,
    this.altitudMetros,
    this.ubicacion,
    this.observaciones,
    required this.creadaEn,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'nombre': nombre, 'superficieHa': superficieHa,
    'tipoSuelo': tipoSuelo, 'tipoCultivo': tipoCultivo,
    'nivelTerreno': nivelTerreno, 'phSuelo': phSuelo,
    'altitudMetros': altitudMetros, 'ubicacion': ubicacion,
    'observaciones': observaciones,
    'creadaEn': creadaEn.toIso8601String(),
  };

  factory Parcela.fromMap(Map<String, dynamic> m) => Parcela(
    id: m['id'], nombre: m['nombre'],
    superficieHa: (m['superficieHa'] as num).toDouble(),
    tipoSuelo: m['tipoSuelo'], tipoCultivo: m['tipoCultivo'],
    nivelTerreno: m['nivelTerreno'],
    phSuelo: m['phSuelo'] != null ? (m['phSuelo'] as num).toDouble() : null,
    altitudMetros: m['altitudMetros'] != null ? (m['altitudMetros'] as num).toDouble() : null,
    ubicacion: m['ubicacion'], observaciones: m['observaciones'],
    creadaEn: DateTime.parse(m['creadaEn']),
  );
}

class Ciclo {
  final String id;
  final String parcelaId;
  final String parcela;
  final DateTime fechaSiembra;
  final String variedad;
  final String tipoMaiz;
  final int densidadPlantas;
  final bool semillaTratada;
  final String? tratamientoSemilla;
  final String preparacionSuelo;
  final String? observaciones;
  int diasTranscurridos;
  double? rendimientoTonHa;
  String? estadoCosecha;

  Ciclo({
    required this.id, required this.parcelaId, required this.parcela,
    required this.fechaSiembra, required this.variedad, required this.tipoMaiz,
    required this.densidadPlantas, required this.semillaTratada,
    this.tratamientoSemilla, required this.preparacionSuelo,
    this.observaciones, this.rendimientoTonHa, this.estadoCosecha,
  }) : diasTranscurridos = DateTime.now().difference(fechaSiembra).inDays;

  Map<String, dynamic> toMap() => {
    'id': id, 'parcelaId': parcelaId, 'parcela': parcela,
    'fechaSiembra': fechaSiembra.toIso8601String(),
    'variedad': variedad, 'tipoMaiz': tipoMaiz,
    'densidadPlantas': densidadPlantas, 'semillaTratada': semillaTratada,
    'tratamientoSemilla': tratamientoSemilla,
    'preparacionSuelo': preparacionSuelo, 'observaciones': observaciones,
    'rendimientoTonHa': rendimientoTonHa, 'estadoCosecha': estadoCosecha,
  };

  factory Ciclo.fromMap(Map<String, dynamic> m) => Ciclo(
    id: m['id'], parcelaId: m['parcelaId'], parcela: m['parcela'],
    fechaSiembra: DateTime.parse(m['fechaSiembra']),
    variedad: m['variedad'], tipoMaiz: m['tipoMaiz'],
    densidadPlantas: m['densidadPlantas'], semillaTratada: m['semillaTratada'],
    tratamientoSemilla: m['tratamientoSemilla'],
    preparacionSuelo: m['preparacionSuelo'], observaciones: m['observaciones'],
    rendimientoTonHa: m['rendimientoTonHa'] != null ? (m['rendimientoTonHa'] as num).toDouble() : null,
    estadoCosecha: m['estadoCosecha'],
  );

  String get etapaCultivo {
    if (diasTranscurridos < 7) return 'Germinacion';
    if (diasTranscurridos < 21) return 'Emergencia (VE-V3)';
    if (diasTranscurridos < 45) return 'Crecimiento (V4-V8)';
    if (diasTranscurridos < 65) return 'Pre-floracion (V9-V12)';
    if (diasTranscurridos < 80) return 'Floracion (VT-R1)';
    if (diasTranscurridos < 110) return 'Llenado de grano (R2-R4)';
    if (diasTranscurridos < 130) return 'Madurez fisiologica (R5-R6)';
    return 'Listo para cosechar';
  }

  List<String> get recomendaciones {
    List<String> r = [];
    if (diasTranscurridos >= 18 && diasTranscurridos <= 25) r.add('Aplicar 1a fertilizacion nitrogenada (Urea 100 kg/ha)');
    if (diasTranscurridos >= 20 && diasTranscurridos <= 30) r.add('Aplicar herbicida pre-emergente si hay maleza');
    if (diasTranscurridos >= 38 && diasTranscurridos <= 50) r.add('Aplicar 2a fertilizacion nitrogenada (Urea 120 kg/ha)');
    if (diasTranscurridos >= 35 && diasTranscurridos <= 55) r.add('Revisar cogollo: riesgo de gusano cogollero');
    if (diasTranscurridos >= 55 && diasTranscurridos <= 65) r.add('Aplicar foliar de zinc y boro para llenado de grano');
    if (diasTranscurridos >= 65 && diasTranscurridos <= 80) r.add('Monitorear floracion, evitar estres hidrico');
    if (diasTranscurridos >= 120) r.add('Evaluar fecha de cosecha segun humedad del grano');
    if (r.isEmpty) r.add('Monitoreo general del cultivo, registrar observaciones');
    return r;
  }
}

class Gasto {
  final String id;
  final String parcelaId;
  final String parcela;
  final String categoria;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String? notas;

  Gasto({
    required this.id, required this.parcelaId, required this.parcela,
    required this.categoria, required this.concepto, required this.monto,
    required this.fecha, this.notas,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'parcelaId': parcelaId, 'parcela': parcela,
    'categoria': categoria, 'concepto': concepto, 'monto': monto,
    'fecha': fecha.toIso8601String(), 'notas': notas,
  };

  factory Gasto.fromMap(Map<String, dynamic> m) => Gasto(
    id: m['id'], parcelaId: m['parcelaId'], parcela: m['parcela'],
    categoria: m['categoria'], concepto: m['concepto'],
    monto: (m['monto'] as num).toDouble(),
    fecha: DateTime.parse(m['fecha']), notas: m['notas'],
  );
}

class Cosecha {
  final String id;
  final String parcelaId;
  final String parcela;
  final DateTime fecha;
  final String tipo; // rastrojo, silo, maiz_grano
  final double rendimientoTonHa;
  final double superficieHa;
  final double precioVentaTon;
  final double costoTotal;
  final String? observaciones;

  Cosecha({
    required this.id, required this.parcelaId, required this.parcela,
    required this.fecha, required this.tipo, required this.rendimientoTonHa,
    required this.superficieHa, required this.precioVentaTon,
    required this.costoTotal, this.observaciones,
  });

  double get produccionTotal => rendimientoTonHa * superficieHa;
  double get ingresoTotal => produccionTotal * precioVentaTon;
  double get ganancia => ingresoTotal - costoTotal;
  double get roi => costoTotal > 0 ? (ganancia / costoTotal) * 100 : 0;

  Map<String, dynamic> toMap() => {
    'id': id, 'parcelaId': parcelaId, 'parcela': parcela,
    'fecha': fecha.toIso8601String(), 'tipo': tipo,
    'rendimientoTonHa': rendimientoTonHa, 'superficieHa': superficieHa,
    'precioVentaTon': precioVentaTon, 'costoTotal': costoTotal,
    'observaciones': observaciones,
  };

  factory Cosecha.fromMap(Map<String, dynamic> m) => Cosecha(
    id: m['id'], parcelaId: m['parcelaId'], parcela: m['parcela'],
    fecha: DateTime.parse(m['fecha']), tipo: m['tipo'],
    rendimientoTonHa: (m['rendimientoTonHa'] as num).toDouble(),
    superficieHa: (m['superficieHa'] as num).toDouble(),
    precioVentaTon: (m['precioVentaTon'] as num).toDouble(),
    costoTotal: (m['costoTotal'] as num).toDouble(),
    observaciones: m['observaciones'],
  );
}

class Diagnostico {
  final String id;
  final String parcelaId;
  final String parcela;
  final DateTime fecha;
  final String problema;
  final String nivel;
  final String descripcion;
  final String recomendacion;
  final String? fotoPath;
  bool tratado;

  Diagnostico({
    required this.id, required this.parcelaId, required this.parcela,
    required this.fecha, required this.problema, required this.nivel,
    required this.descripcion, required this.recomendacion,
    this.fotoPath, this.tratado = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'parcelaId': parcelaId, 'parcela': parcela,
    'fecha': fecha.toIso8601String(), 'problema': problema,
    'nivel': nivel, 'descripcion': descripcion,
    'recomendacion': recomendacion, 'fotoPath': fotoPath, 'tratado': tratado,
  };

  factory Diagnostico.fromMap(Map<String, dynamic> m) => Diagnostico(
    id: m['id'], parcelaId: m['parcelaId'], parcela: m['parcela'],
    fecha: DateTime.parse(m['fecha']), problema: m['problema'],
    nivel: m['nivel'], descripcion: m['descripcion'],
    recomendacion: m['recomendacion'], fotoPath: m['fotoPath'],
    tratado: m['tratado'] ?? false,
  );
}

class MensajeChat {
  final String rol;
  final String texto;
  final DateTime fecha;
  MensajeChat({required this.rol, required this.texto, required this.fecha});
}
