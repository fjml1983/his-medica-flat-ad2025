import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paciente.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class FhirService {
  String get baseUrl {
    if (kIsWeb) {
      // En web normalmente usarás 'http://localhost:8080' si el servidor corre localmente
      // y el navegador permite CORS; en producción usa la URL pública HTTPS.
      return 'http://localhost:8080/fhir/Patient';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Emulador Android usa 10.0.2.2 para apuntar al host
        return 'http://10.0.2.2:8080/fhir/Patient';
      case TargetPlatform.iOS:
        // Simulador iOS suele usar localhost
        return 'http://127.0.0.1:8080/fhir/Patient';
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Desktop: localhost
        return 'http://127.0.0.1:8080/fhir/Patient';
      default:
        return 'http://127.0.0.1:8080/fhir/Patient';
    }
  }

  static const String ehrExtensionUrl =
      'http://hismedica.local/StructureDefinition/ehrId';

  // Crear paciente
  Future<Map<String, dynamic>?> crearPaciente(Paciente paciente) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/fhir+json"},
      body: jsonEncode(paciente.toFhirJson()),
    );

    print("POST status: ${response.statusCode}");
    print("POST body: ${response.body}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        if (response.body.isNotEmpty) {
          final bodyJson = jsonDecode(response.body);
          final id = bodyJson['id'] ?? (bodyJson['resource']?['id']);
          return {'id': id, 'resource': bodyJson};
        } else {
          final location =
              response.headers['location'] ??
              response.headers['content-location'];
          if (location != null && location.isNotEmpty) {
            final segments = Uri.parse(location).pathSegments;
            final idx = segments.indexOf('Patient');
            if (idx >= 0 && idx + 1 < segments.length) {
              final id = segments[idx + 1];
              return {'id': id, 'resource': null};
            } else {
              final last = segments.isNotEmpty ? segments.last : null;
              return {'id': last, 'resource': null};
            }
          }
        }
      } catch (e) {
        print('Error parseando respuesta de crearPaciente: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> addEhrExtension(String patientId, String ehrId) async {
    final url = '$baseUrl/$patientId';
    final patchBody = [
      {
        "op": "add",
        "path": "/extension/-",
        "value": {"url": ehrExtensionUrl, "valueString": ehrId},
      },
    ];

    final response = await http.patch(
      Uri.parse(url),
      headers: {"Content-Type": "application/json-patch+json"},
      body: jsonEncode(patchBody),
    );

    print('PATCH addEhrExtension status: ${response.statusCode}');
    print('PATCH body: ${response.body}');

    return response.statusCode == 200;
  }

  // Actualizar paciente (PUT)
  Future<bool> actualizarPaciente(String id, Paciente paciente) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/fhir+json"},
      body: jsonEncode(paciente.toFhirJson()),
    );
    print('PUT status: ${response.statusCode}');
    print('PUT body: ${response.body}');
    return response.statusCode == 200;
  }

  // Eliminar paciente (DELETE)
  Future<bool> eliminarPaciente(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    print("DELETE status: ${response.statusCode}");
    print("DELETE body: ${response.body}");
    return response.statusCode == 204 || response.statusCode == 200;
    // return response.statusCode == 204;
  }

  // Obtener lista de pacientes con idFhir para edición/eliminación
  Future<List<Paciente>> obtenerPacientes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final entries = (jsonData['entry'] as List<dynamic>?);
      if (entries == null) {
        return [];
      }
      return entries.where((e) => e['resource'] != null).map((e) {
        final resource = e['resource'];
        final id = resource['id'] ?? '';
        final paciente = Paciente.fromFhirJson(resource);
        paciente.idFhir = id;
        return paciente;
      }).toList();
    }
    return [];
  }
}
