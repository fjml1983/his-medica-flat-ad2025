import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  static const String _dbName = 'catalogos.db';
  static const String _assetPath = 'assets/catalogos.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, _dbName);

    final dbFile = File(path);
    if (!await dbFile.exists()) {
      final data = await rootBundle.load(_assetPath);
      final bytes = data.buffer.asUint8List();
      await Directory(dirname(path)).create(recursive: true);
      await dbFile.writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, readOnly: true);
  }

  Future<void> forceRecopy() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, _dbName);
    if (await File(path).exists()) {
      await deleteDatabase(path);
    }
    _database = null;
    await database;
  }

  // Utilidad: revisar si existe una columna en una tabla
  Future<bool> _hasColumn(Database db, String table, String column) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    return info.any(
      (c) => (c['name'] ?? '').toString().toLowerCase() == column.toLowerCase(),
    );
  }

  // Entidades
  Future<List<Map<String, dynamic>>> getEntidades() async {
    final db = await database;
    return await db.query('entidades', orderBy: 'nombre COLLATE NOCASE ASC');
  }

  // Municipios: filtra SOLO por clave_entidad (tu schema mostró que c_estado no existe aquí)
  Future<List<Map<String, dynamic>>> getMunicipios(String claveEntidad) async {
    final db = await database;
    return await db.query(
      'municipios',
      where: 'clave_entidad = ?',
      whereArgs: [claveEntidad],
    );
  }

  // CPs: estrategia inteligente que intenta varias combinaciones
  Future<List<Map<String, dynamic>>> getCodigosPostalesSmart({
    required String cEstado, // p. ej. '11'
    required String cMnpio3, // p. ej. '046'
    String? municipioNombre, // opcional, fallback por nombre
  }) async {
    final db = await database;

    // Normalizaciones
    final cMnpio3Pad = cMnpio3.padLeft(3, '0');
    final cMnpioInt = int.tryParse(cMnpio3) ?? int.tryParse(cMnpio3Pad);
    final combinado = '$cEstado$cMnpio3Pad'; // 11046

    // Detección de columnas disponibles
    final hasCEstado = await _hasColumn(db, 'codigos_postales', 'c_estado');
    final hasCMnpio = await _hasColumn(db, 'codigos_postales', 'c_mnpio');
    final hasMunId = await _hasColumn(db, 'codigos_postales', 'municipio_id');
    final hasDMnpio = await _hasColumn(db, 'codigos_postales', 'd_mnpio');

    // a) SEPOMEX típico: c_estado + c_mnpio (texto 3 dígitos)
    if (hasCEstado && hasCMnpio) {
      // intento con texto 3 dígitos
      final a1 = await db.query(
        'codigos_postales',
        where: 'c_estado = ? AND c_mnpio = ?',
        whereArgs: [cEstado, cMnpio3Pad],
        orderBy: 'CAST(d_codigo AS INT) ASC',
      );
      if (a1.isNotEmpty) {
        // print para depuración
        // print('[CP] match a1: c_estado=$cEstado, c_mnpio=$cMnpio3Pad -> ${a1.length}');
        return a1;
      }
      // intento con entero por si c_mnpio es integer
      if (cMnpioInt != null) {
        final a2 = await db.query(
          'codigos_postales',
          where: 'c_estado = ? AND c_mnpio = ?',
          whereArgs: [cEstado, cMnpioInt],
          orderBy: 'CAST(d_codigo AS INT) ASC',
        );
        if (a2.isNotEmpty) {
          // print('[CP] match a2: c_estado=$cEstado, c_mnpio(int)=$cMnpioInt -> ${a2.length}');
          return a2;
        }
      }
    }

    // b) Algunos esquemas usan municipio_id = 11046
    if (hasMunId) {
      // como texto
      final b1 = await db.query(
        'codigos_postales',
        where: 'municipio_id = ?',
        whereArgs: [combinado],
        orderBy: 'CAST(d_codigo AS INT) ASC',
      );
      if (b1.isNotEmpty) {
        // print('[CP] match b1: municipio_id=$combinado -> ${b1.length}');
        return b1;
      }
      // como entero
      final combInt = int.tryParse(combinado);
      if (combInt != null) {
        final b2 = await db.query(
          'codigos_postales',
          where: 'municipio_id = ?',
          whereArgs: [combInt],
          orderBy: 'CAST(d_codigo AS INT) ASC',
        );
        if (b2.isNotEmpty) {
          // print('[CP] match b2: municipio_id(int)=$combInt -> ${b2.length}');
          return b2;
        }
      }
    }

    // c) Fallback por nombre del municipio + estado (si existen columnas)
    if (municipioNombre != null &&
        municipioNombre.trim().isNotEmpty &&
        hasCEstado &&
        hasDMnpio) {
      final c1 = await db.query(
        'codigos_postales',
        where: 'c_estado = ? AND lower(d_mnpio) = lower(?)',
        whereArgs: [cEstado, municipioNombre.trim()],
        orderBy: 'CAST(d_codigo AS INT) ASC',
      );
      if (c1.isNotEmpty) {
        // print('[CP] match c1: c_estado=$cEstado, d_mnpio=$municipioNombre -> ${c1.length}');
        return c1;
      }
    }

    // Si no hubo match, regresa vacío
    return <Map<String, dynamic>>[];
  }
}
