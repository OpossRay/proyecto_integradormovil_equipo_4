import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final ruta = join(await getDatabasesPath(), 'notas.db');

    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            contenido TEXT NOT NULL,
            pendiente_sincronizar INTEGER NOT NULL DEFAULT 1
          )
        ''');
      },
    );

    return _db!;
  }

  // Insertar una nota
  static Future<int> insertar(String titulo, String contenido) async {
    final db = await database;

    return db.insert('notas', {
      'titulo': titulo,
      'contenido': contenido,
      'pendiente_sincronizar': 1,
    });
  }

  // Consultar las notas
  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await database;

    return db.query('notas', orderBy: 'id DESC');
  }

  // Actualizar una nota
  static Future<int> actualizar(int id, String titulo, String contenido) async {
    final db = await database;

    return db.update(
      'notas',
      {'titulo': titulo, 'contenido': contenido, 'pendiente_sincronizar': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar una nota
  static Future<int> eliminar(int id) async {
    final db = await database;

    return db.delete('notas', where: 'id = ?', whereArgs: [id]);
  }
}
