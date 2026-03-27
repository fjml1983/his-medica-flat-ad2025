import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/patient_model.dart';

class EhrService {
  // Singleton pattern
  static final EhrService _instance = EhrService._internal();
  factory EhrService() => _instance;
  EhrService._internal();

  // ==================== PACIENTES ====================

  /// Crear un nuevo EHR (paciente) - Versión simplificada
  // Reemplaza la función createEhr por esta versión que devuelve solo el ehrId (String)
  Future<String> createEhr(String patientName) async {
    try {
      final response = await http.post(
        Uri.parse(
          AppConstants.createEhrEndpoint(),
        ), // asegúrate que retorna la URL correcta
        headers: {
          "Prefer": "return=representation",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ajusta la ruta según lo que devuelve tu EHRbase.
        // Muchas instalaciones devuelven algo como data['ehr_id']['value'] o data['ehr_id'].
        String? ehrId;
        if (data is Map && data.containsKey('ehr_id')) {
          final v = data['ehr_id'];
          if (v is Map && v.containsKey('value'))
            ehrId = v['value'] as String?;
          else if (v is String)
            ehrId = v;
        }

        // Fallback: intenta buscar en otras posiciones comunes
        ehrId ??=
            (data['id'] as String?) ??
            (data['ehrId'] as String?) ??
            (data['ehr_id'] as String?);

        if (ehrId == null || ehrId.isEmpty) {
          throw Exception(
            'No se pudo extraer ehrId de la respuesta: ${response.body}',
          );
        }
        return ehrId;
      } else {
        throw Exception(
          'Error al crear EHR: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al crear EHR: $e');
    }
  }

  /// Obtener información de un EHR
  Future<Map<String, dynamic>> createComposition(
    String ehrId,
    Map<String, dynamic> compositionData,
  ) async {
    try {
      final url = AppConstants.compositionEndpointForEhr(ehrId);

      // ← ELIMINAR campos problemáticos
      compositionData.remove(
        'his_medica_itsur.historia_clinica_nom004.v1/name|value',
      );
      compositionData.remove(
        'his_medica_itsur.historia_clinica_nom004.v1/_name',
      );

      print('📝 ===== CREAR COMPOSICIÓN =====');
      print('🌐 URL: $url');
      print('📊 Total de campos: ${compositionData.length}');
      print('================================');

      final response = await http.post(
        Uri.parse(url),
        headers: AppConstants.compositionHeadersFlat(),
        body: jsonEncode(compositionData),
      );

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ ¡COMPOSICIÓN CREADA EXITOSAMENTE! 🎉');
        print('📄 Response completo:');
        print(response.body);
        return jsonDecode(response.body);
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        final lowerBody = response.body.toLowerCase();
        if (response.statusCode == 404 ||
            lowerBody.contains('template') ||
            lowerBody.contains('templateid')) {
          throw Exception(
            'No se pudo crear la composición porque el template '
            '"${AppConstants.templateId}" no está disponible en EHRbase.\n'
            '1) Carga arquetipos (.adl): ./scripts/upload-ehr-archetypes.ps1\n'
            '2) Carga templates (.opt/.xml): ./scripts/upload-ehr-templates.ps1\n'
            '3) Verifica templates en: ${AppConstants.templateListEndpoint}\n\n'
            'Detalle técnico (${response.statusCode}): ${response.body}',
          );
        }
        throw Exception(
          'Error al crear composición: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      print('💥 Excepción: $e');
      throw Exception('Error de conexión al crear composición: $e');
    }
  }

  /// Obtener todas las composiciones de un paciente usando AQL
  Future<List<Map<String, dynamic>>> getCompositions(String ehrId) async {
    try {
      final aqlQuery =
          '''
      SELECT 
        c/uid/value as uid,
        c/context/start_time/value as start_time,
        c/composer/name as composer_name,
        c/context/health_care_facility/name as facility_name,
        c/content[openEHR-EHR-EVALUATION.reason_for_encounter.v1]/data[at0001]/items[at0002]/value/value as reason
      FROM EHR e
      CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.encounter.v1]
      WHERE e/ehr_id/value = '$ehrId'
      AND c/archetype_details/template_id/value = '${AppConstants.templateId}'
      ORDER BY c/context/start_time/value DESC
    ''';

      final response = await http.post(
        Uri.parse(AppConstants.queryEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({'q': aqlQuery}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rows = data['rows'] as List? ?? [];

        return rows.map((row) {
          final fullUid = row[0] as String;
          print('📋 UID completo desde AQL: $fullUid'); // Debug

          return {
            'uid': fullUid, // Guardamos el UID completo
            'start_time': row[1],
            'composer_name': row[2],
            'facility_name': row[3],
            'reason': row[4] ?? 'Sin motivo especificado',
          };
        }).toList();
      } else {
        throw Exception(
          'Error al consultar composiciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al consultar composiciones: $e');
    }
  }

  /// Obtener una composición específica por UID
  /// Obtener composición usando EHR ID + versioned UID (NUEVO MÉTODO)
  Future<Map<String, dynamic>> getCompositionByUidWithEhrId(
    String ehrId,
    String compositionUid,
  ) async {
    try {
      print('🎯 ===== getCompositionByUidWithEhrId =====');
      print('👤 EHR ID: $ehrId');
      print('🔑 Composition UID: $compositionUid');

      // Extraer el UUID limpio
      final parts = compositionUid.split('::');
      final cleanUid = parts[0];
      print('✂️ UUID limpio: $cleanUid');

      // Intentar diferentes URLs usando el EHR ID
      final urls = [
        // Opción 1: A través del EHR con versioned object uid
        '${AppConstants.ehrbaseUrl}${AppConstants.ehrbaseBasePath}/ehr/$ehrId/composition/$cleanUid?format=FLAT',

        // Opción 2: A través del EHR con UID completo
        '${AppConstants.ehrbaseUrl}${AppConstants.ehrbaseBasePath}/ehr/$ehrId/composition/$compositionUid?format=FLAT',

        // Opción 3: Sin formato FLAT
        '${AppConstants.ehrbaseUrl}${AppConstants.ehrbaseBasePath}/ehr/$ehrId/composition/$cleanUid',
      ];

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        print('🌐 Intento ${i + 1}: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {"Accept": "application/json"},
        );

        print('📥 Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          print('✅ ¡Composición encontrada!');
          return jsonDecode(response.body);
        } else if (response.statusCode == 404) {
          print('⚠️ No encontrada, probando siguiente...');
          if (i < urls.length - 1) continue;
        } else {
          print('❌ Error ${response.statusCode}: ${response.body}');
        }
      }

      throw Exception(
        'No se pudo obtener la composición.\n'
        'EHR ID: $ehrId\n'
        'Composition UID: $compositionUid',
      );
    } catch (e, stackTrace) {
      print('❌ Excepción: $e');
      print('📍 StackTrace: $stackTrace');
      throw Exception('Error al obtener composición: $e');
    }
  }

  /// Actualizar una composición existente
  Future<Map<String, dynamic>> updateComposition(
    String compositionUid,
    Map<String, dynamic> compositionData,
  ) async {
    try {
      final versionedUid = compositionUid.split('::')[0];

      final response = await http.put(
        Uri.parse(
          '${AppConstants.ehrbaseUrl}${AppConstants.ehrbaseBasePath}/composition/$versionedUid?format=FLAT',
        ),
        headers: AppConstants.compositionHeadersFlat(),
        body: jsonEncode(compositionData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error al actualizar composición: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar composición: $e');
    }
  }

  /// Eliminar una composición
  Future<void> deleteComposition(String compositionUid) async {
    try {
      final versionedUid = compositionUid.split('::')[0];

      final response = await http.delete(
        Uri.parse(
          '${AppConstants.ehrbaseUrl}${AppConstants.ehrbaseBasePath}/composition/$versionedUid',
        ),
        headers: AppConstants.jsonHeaders,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error al eliminar composición: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar composición: $e');
    }
  }

  // ==================== UTILIDADES ====================

  /// Generar estructura base de composición con valores por defecto
  Map<String, dynamic> generateBaseComposition({
    required String composerName,
    String facilityName = 'ITSUR',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();

    return {
      '${AppConstants.templatePath}/category|terminology':
          AppConstants.openehrTerminology,
      '${AppConstants.templatePath}/category|code':
          AppConstants.eventCategoryCode,
      '${AppConstants.templatePath}/category|value':
          AppConstants.eventCategoryValue,
      '${AppConstants.templatePath}/context/start_time': now,
      '${AppConstants.templatePath}/context/setting|terminology':
          AppConstants.openehrTerminology,
      '${AppConstants.templatePath}/context/setting|value':
          AppConstants.homeSettingValue,
      '${AppConstants.templatePath}/context/setting|code':
          AppConstants.homeSettingCode,
      '${AppConstants.templatePath}/context/_end_time': now,
      '${AppConstants.templatePath}/context/_health_care_facility|name':
          facilityName,
      '${AppConstants.templatePath}/language|code':
          AppConstants.defaultLanguage,
      '${AppConstants.templatePath}/language|terminology':
          AppConstants.iso639Terminology,
      '${AppConstants.templatePath}/territory|code':
          AppConstants.defaultTerritory,
      '${AppConstants.templatePath}/territory|terminology':
          AppConstants.iso3166Terminology,
      '${AppConstants.templatePath}/composer|name': composerName,
    };
  }

  /// Validar conexión con EHRbase
  Future<bool> validateConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse(AppConstants.templateListEndpoint),
            headers: AppConstants.jsonHeaders,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  /// Obtener ejemplo del template en formato FLAT
  Future<Map<String, dynamic>> getTemplateExample() async {
    try {
      final response = await http.get(
        Uri.parse(
          AppConstants.templateExampleEndpoint(AppConstants.templateId),
        ),
        headers: AppConstants.jsonHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error al obtener ejemplo del template: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener ejemplo: $e');
    }
  }
}
