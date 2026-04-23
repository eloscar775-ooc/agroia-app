// lib/services/ia_service.dart
import '../models/models.dart';

class IAService {
  // Base de conocimiento local sobre maiz
  static const _plagas = {
    'gusano cogollero': {
      'sintomas': ['perforaciones cogollo', 'aserrin', 'larvas', 'hojas comidas', 'cogollo danado'],
      'nivel': 'alto',
      'descripcion': 'Spodoptera frugiperda. Larvas que atacan el cogollo del maiz en etapas V3-V8.',
      'control': 'Clorpirifos 48% EC 1.5 L/ha + Cipermetrina 20% 0.4 L/ha. Aplicar tarde-noche.',
      'prevencion': 'Monitorear 2 veces por semana. Umbral: 2+ larvas por planta.',
    },
    'pulgon': {
      'sintomas': ['colonias pequenas', 'hojas enrolladas', 'melaza', 'hormigas', 'manchas amarillas'],
      'nivel': 'medio',
      'descripcion': 'Rhopalosiphum maidis. Colonias en hojas y espigas.',
      'control': 'Imidacloprid 35% SC 0.5 L/ha o Pirimicarb 50% WG 0.5 kg/ha.',
      'prevencion': 'Favorecer enemigos naturales. Evitar exceso de nitrogeno.',
    },
    'trips': {
      'sintomas': ['plateado hojas', 'raspado superficial', 'puntos plateados', 'hojas deformadas'],
      'nivel': 'medio',
      'descripcion': 'Frankliniella williamsi. Raspa y chupa en hojas jovenes.',
      'control': 'Spinosad 48% SC 0.15 L/ha. En sequia son mas dañinos.',
      'prevencion': 'Riego oportuno reduce poblaciones.',
    },
    'diabrotica': {
      'sintomas': ['raiz comida', 'plantas tumbadas', 'adultos en mazorca', 'seda comida'],
      'nivel': 'alto',
      'descripcion': 'Diabrotica virgifera. Larvas en raiz, adultos en espiga.',
      'control': 'Clorpirifos al suelo en siembra. Adultos: Malatión 1 L/ha.',
      'prevencion': 'Rotacion de cultivos es el mejor control.',
    },
  };

  static const _enfermedades = {
    'roya comun': {
      'sintomas': ['pustulas cafes', 'polvo cafe', 'manchas ovaladas', 'ambos lados hoja'],
      'nivel': 'medio',
      'descripcion': 'Puccinia sorghi. Hongos en hoja, favorecido por humedad.',
      'control': 'Tebuconazol 25% EC 0.5 L/ha o Propiconazol 25% EC 0.5 L/ha.',
      'prevencion': 'Variedades resistentes. Aplicar fungicida preventivo en floracion.',
    },
    'tizon foliar': {
      'sintomas': ['lesiones grises', 'bordes cafe', 'manchas alargadas', 'necrosis foliar'],
      'nivel': 'alto',
      'descripcion': 'Exserohilum turcicum. Manchas grandes en hojas medias y superiores.',
      'control': 'Mancozeb 80% WP 2.5 kg/ha. Aplicar al inicio de sintomas.',
      'prevencion': 'Evitar monocultivo. Sembrar en fecha optima.',
    },
    'carbon comun': {
      'sintomas': ['agallas negras', 'bolsas polvo negro', 'tumores', 'masas esporas'],
      'nivel': 'medio',
      'descripcion': 'Ustilago maydis. Tumores llenos de esporas negras.',
      'control': 'No hay control quimico efectivo. Eliminar plantas enfermas.',
      'prevencion': 'Semilla tratada con Carboxin+Thiram. Evitar dano mecanico.',
    },
    'pudricion tallo': {
      'sintomas': ['tallo blando', 'plantas caidas', 'medula desintegrada', 'mal olor'],
      'nivel': 'alto',
      'descripcion': 'Fusarium spp / Pythium spp. Pudricion interna del tallo.',
      'control': 'No hay control efectivo al momento del sintoma.',
      'prevencion': 'Drenaje, densidad optima, semilla tratada, potasio adecuado.',
    },
  };

  static const _deficiencias = {
    'nitrogeno': {
      'sintomas': ['amarillamiento', 'amarillo en V de hojas viejas', 'hojas palidas', 'crecimiento lento'],
      'nivel': 'medio',
      'descripcion': 'Deficiencia de Nitrogeno (N). El mas comun en maiz.',
      'control': 'Urea 46% 100-150 kg/ha. Aplicar en suelo humedo.',
      'prevencion': 'Aplicar nitrogeno en 2-3 fracciones segun etapa.',
    },
    'fosforo': {
      'sintomas': ['coloracion purpura', 'purpura en tallos y hojas', 'raices poco desarrolladas'],
      'nivel': 'medio',
      'descripcion': 'Deficiencia de Fosforo (P). Critico en etapas tempranas.',
      'control': 'DAP 18-46-0 a 80 kg/ha o Triple superfosfato.',
      'prevencion': 'Aplicar al momento de siembra. pH entre 6-7 mejora disponibilidad.',
    },
    'zinc': {
      'sintomas': ['franjas blancas en hojas', 'rayas amarillas en base hoja', 'hojas nuevas blancuzcas'],
      'nivel': 'bajo',
      'descripcion': 'Deficiencia de Zinc (Zn). Comun en suelos alcalinos o muy arenosos.',
      'control': 'Sulfato de zinc 33% a 5 kg/ha al suelo o foliar 0.5% en agua.',
      'prevencion': 'Aplicar zinc en siembra en suelos deficientes.',
    },
    'potasio': {
      'sintomas': ['bordes hojas quemados', 'necrosis bordes', 'plantas debiles', 'caida facil'],
      'nivel': 'medio',
      'descripcion': 'Deficiencia de Potasio (K). Hojas con bordes quemados de abajo hacia arriba.',
      'control': 'Cloruro de potasio 60% a 80 kg/ha.',
      'prevencion': 'Incluir potasio en programa de fertilizacion.',
    },
  };

  /// Analiza texto/descripcion del usuario y devuelve diagnostico
  static Map<String, dynamic> analizarDescripcion(String descripcion, {List<Map<String, String>> documentos = const []}) {
    final texto = descripcion.toLowerCase();
    double mejorScore = 0;
    String mejorProblema = '';
    Map<String, dynamic> mejorDatos = {};

    // Buscar en plagas
    _plagas.forEach((nombre, datos) {
      final sintomas = datos['sintomas'] as List;
      int coincidencias = 0;
      for (final s in sintomas) {
        if (texto.contains(s as String)) coincidencias++;
      }
      final score = coincidencias / sintomas.length;
      if (score > mejorScore) {
        mejorScore = score;
        mejorProblema = nombre;
        mejorDatos = {'tipo': 'plaga', ...datos};
      }
    });

    // Buscar en enfermedades
    _enfermedades.forEach((nombre, datos) {
      final sintomas = datos['sintomas'] as List;
      int coincidencias = 0;
      for (final s in sintomas) {
        if (texto.contains(s as String)) coincidencias++;
      }
      final score = coincidencias / sintomas.length;
      if (score > mejorScore) {
        mejorScore = score;
        mejorProblema = nombre;
        mejorDatos = {'tipo': 'enfermedad', ...datos};
      }
    });

    // Buscar en deficiencias
    _deficiencias.forEach((nombre, datos) {
      final sintomas = datos['sintomas'] as List;
      int coincidencias = 0;
      for (final s in sintomas) {
        if (texto.contains(s as String)) coincidencias++;
      }
      final score = coincidencias / sintomas.length;
      if (score > mejorScore) {
        mejorScore = score;
        mejorProblema = nombre;
        mejorDatos = {'tipo': 'deficiencia', ...datos};
      }
    });

    // Buscar en documentos del usuario
    String extraDocInfo = '';
    for (final doc in documentos) {
      final contenido = (doc['contenido'] ?? '').toLowerCase();
      if (texto.split(' ').any((palabra) => palabra.length > 4 && contenido.contains(palabra))) {
        extraDocInfo = '\n\nInformacion adicional de tu documento "${doc['nombre']}": consulta las paginas relevantes.';
      }
    }

    if (mejorScore < 0.1 || mejorProblema.isEmpty) {
      return {
        'problema': 'Problema no identificado',
        'tipo': 'desconocido',
        'nivel': 'bajo',
        'confianza': 10,
        'descripcion': 'No pude identificar el problema con la descripcion proporcionada. Intenta ser mas especifico sobre los sintomas visuales.$extraDocInfo',
        'recomendacion': 'Describe mejor los sintomas: color de las hojas, partes afectadas, textura, si hay insectos, etc.',
      };
    }

    return {
      'problema': mejorProblema.toUpperCase()[0] + mejorProblema.substring(1),
      'tipo': mejorDatos['tipo'],
      'nivel': mejorDatos['nivel'],
      'confianza': (mejorScore * 100).round().clamp(30, 95),
      'descripcion': (mejorDatos['descripcion'] as String) + extraDocInfo,
      'recomendacion': mejorDatos['control'],
      'prevencion': mejorDatos['prevencion'],
    };
  }

  /// Genera respuesta de chat con logica agronomica
  static String responderChat(
    String pregunta, {
    required List<Ciclo> ciclos,
    required List<Parcela> parcelas,
    required List<Cosecha> cosechas,
    required List<Map<String, String>> documentos,
    required List<Map<String, dynamic>> feedback,
  }) {
    final p = pregunta.toLowerCase();

    // Contexto de documentos
    String contextoDoc = '';
    for (final doc in documentos) {
      final contenido = (doc['contenido'] ?? '').toLowerCase();
      final palabras = p.split(' ').where((w) => w.length > 4);
      if (palabras.any((w) => contenido.contains(w))) {
        contextoDoc = ' Segun tu documento "${doc['nombre']}", hay informacion relevante al respecto.';
      }
    }

    // Aprendizaje de feedback previo
    String aprendizaje = '';
    for (final fb in feedback) {
      if (fb['contexto'] != null && p.contains((fb['contexto'] as String).toLowerCase().split(' ').first)) {
        aprendizaje = ' Recordando tu experiencia previa: ${fb['resultado']}.';
      }
    }

    // Preguntas sobre fertilizacion
    if (p.contains('fertiliz') || p.contains('urea') || p.contains('nitrogeno') || p.contains('abono')) {
      if (ciclos.isEmpty) return 'No tienes ciclos activos registrados. Agrega una parcela y un ciclo primero para darte recomendaciones especificas.';
      final ciclo = ciclos.first;
      final dias = ciclo.diasTranscurridos;
      if (dias < 15) return 'Tu cultivo esta en germinacion (dia $dias). Aun no es momento de fertilizar. Espera a que emerja bien.$aprendizaje$contextoDoc';
      if (dias >= 18 && dias <= 25) return 'MOMENTO OPTIMO de 1a fertilizacion nitrogenada (dia $dias de ${ciclo.parcela}). Aplica Urea 46% a 100-120 kg/ha cuando el suelo este humedo, preferente en la tarde.$aprendizaje$contextoDoc';
      if (dias >= 38 && dias <= 50) return 'Es momento de la 2a fertilizacion (dia $dias). Aplica Urea 120-150 kg/ha o puedes complementar con sulfato de amonio. Si el suelo es arenoso, divide en 2 aplicaciones.$aprendizaje$contextoDoc';
      if (dias >= 55 && dias <= 65) return 'En esta etapa (dia $dias) aplica foliar de zinc y boro para mejorar el llenado de grano. Dosis: Sulfato de zinc 0.5% + acido borico 0.2% en 200L de agua.$aprendizaje$contextoDoc';
      return 'Tu cultivo tiene $dias dias (${ciclo.etapaCultivo}). Para esta etapa: ${ciclo.recomendaciones.join(". ")}.$aprendizaje$contextoDoc';
    }

    // Preguntas sobre plagas
    if (p.contains('plaga') || p.contains('gusano') || p.contains('insecto') || p.contains('bicho')) {
      String riesgo = ciclos.isNotEmpty && ciclos.first.diasTranscurridos >= 35 && ciclos.first.diasTranscurridos <= 55
          ? 'ALERTA: Tu cultivo esta en la etapa de mayor riesgo para gusano cogollero (dia ${ciclos.first.diasTranscurridos}). '
          : '';
      return '${riesgo}Las plagas mas comunes en maiz son:\n'
          '1. Gusano cogollero (V3-V8): revisar cogollo, control con Clorpirifos 1.5 L/ha\n'
          '2. Pulgon: colonias en hojas, control con Imidacloprid\n'
          '3. Diabrotica: larvas en raiz, control preventivo al sembrar\n'
          '4. Trips: en sequia, raspado de hojas, control con Spinosad\n'
          'Describe los sintomas que ves para un diagnostico especifico.$aprendizaje$contextoDoc';
    }

    // Preguntas sobre clima/riego
    if (p.contains('riego') || p.contains('agua') || p.contains('lluvia') || p.contains('humedad')) {
      return 'El maiz necesita entre 500-800mm de agua por ciclo. Etapas criticas:\n'
          '- Germinacion: suelo humedo al 70%\n'
          '- V6-V8: no debe faltar agua\n'
          '- Floracion: etapa mas critica, estres reduce 30-50% rendimiento\n'
          '- Llenado de grano: mantener humedad hasta madurez fisiologica\n'
          'En temporal, una lluvia de 20mm cada 7-10 dias es suficiente.$aprendizaje$contextoDoc';
    }

    // Preguntas sobre rendimiento/cosecha
    if (p.contains('rendimiento') || p.contains('cosecha') || p.contains('tonelada') || p.contains('produccion')) {
      if (cosechas.isNotEmpty) {
        final promedio = cosechas.map((c) => c.rendimientoTonHa).reduce((a, b) => a + b) / cosechas.length;
        return 'Tu rendimiento promedio historico es ${promedio.toStringAsFixed(1)} ton/ha. '
            'Para mejorar: 1) Usa semilla mejorada certificada, 2) Aplica nitrogeno en momentos optimos, '
            '3) Controla plagas temprano, 4) Evita estres hidrico en floracion. '
            'Con buen manejo puedes llegar a 8-12 ton/ha.$aprendizaje$contextoDoc';
      }
      return 'El rendimiento potencial del maiz en Jalisco es de 8-12 ton/ha con buen manejo. '
          'Los factores clave son: variedad de alta calidad, fertilizacion oportuna, control de plagas y riego en momentos criticos.$aprendizaje$contextoDoc';
    }

    // Preguntas sobre siembra
    if (p.contains('sembrar') || p.contains('siembra') || p.contains('variedad') || p.contains('semilla')) {
      return 'Para Jalisco, las mejores epocas de siembra son:\n'
          '- Primavera-Verano (PV): Mayo-Junio con lluvia\n'
          '- Otono-Invierno (OI): Noviembre-Diciembre con riego\n'
          'Variedades recomendadas: H-59, H-67, P30F35, DK-357 (tardias) o H-49, Asgrow (tempranas)\n'
          'Densidad: 60,000-80,000 plantas/ha segun variedad y humedad.$aprendizaje$contextoDoc';
    }

    // Preguntas sobre costos
    if (p.contains('costo') || p.contains('gasto') || p.contains('dinero') || p.contains('precio')) {
      return 'Los costos tipicos por hectarea en Jalisco:\n'
          '- Preparacion suelo: \$2,500-4,000\n'
          '- Semilla: \$2,500-5,000\n'
          '- Fertilizantes: \$6,000-10,000\n'
          '- Herbicidas: \$1,500-2,500\n'
          '- Insecticidas: \$1,000-2,000\n'
          '- Cosecha: \$2,000-3,500\n'
          '- TOTAL: ~\$15,000-27,000/ha\n'
          'Registra todos tus gastos en la app para un calculo exacto.$aprendizaje$contextoDoc';
    }

    // Respuesta generica con informacion util
    return 'Entiendo tu pregunta sobre: "$pregunta". \n\n'
        'Como asistente de AgroIA, puedo ayudarte con:\n'
        '- Diagnostico de plagas y enfermedades\n'
        '- Recomendaciones de fertilizacion por etapa\n'
        '- Manejo del riego\n'
        '- Calculo de costos y rendimientos\n'
        '- Analisis de tus datos historicos\n\n'
        'Preguntame algo especifico sobre tu cultivo.$aprendizaje$contextoDoc';
  }
}
