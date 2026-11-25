import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TareasDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final ruta = join(await getDatabasesPath(), 'tareas.db');

    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tareas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            completada INTEGER NOT NULL DEFAULT 0,
            fecha_creacion TEXT NOT NULL,
            pendiente_sincronizar INTEGER NOT NULL DEFAULT 1
          )
        ''');
      },
    );

    return _db!;
  }

  // Crear una tarea
  static Future<int> insertar(String titulo, String descripcion) async {
    final db = await database;

    return db.insert('tareas', {
      'titulo': titulo,
      'descripcion': descripcion,
      'completada': 0,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'pendiente_sincronizar': 1,
    });
  }

  // Consultar las tareas
  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await database;

    return db.query('tareas', orderBy: 'id DESC');
  }

  // Actualizar una tarea
  static Future<int> actualizar(
    int id,
    String titulo,
    String descripcion,
  ) async {
    final db = await database;

    return db.update(
      'tareas',
      {
        'titulo': titulo,
        'descripcion': descripcion,
        'pendiente_sincronizar': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cambiar el estado de una tarea
  static Future<int> cambiarEstado(int id, bool completada) async {
    final db = await database;

    return db.update(
      'tareas',
      {'completada': completada ? 1 : 0, 'pendiente_sincronizar': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar una tarea
  static Future<int> eliminar(int id) async {
    final db = await database;

    return db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }
}
