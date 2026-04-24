import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _fileName = 'expense_tracker.db';
  static const int _version = 1;

  static Database? _db;

  static Future<Database> instance() async {
    final cached = _db;
    if (cached != null) return cached;
    final dir = await getDatabasesPath();
    final path = p.join(dir, _fileName);
    final db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
    _db = db;
    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        icon_code INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount_cents INTEGER NOT NULL,
        note TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        spent_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.insert('categories', {
      'name': 'Comida',
      'color_hex': 'FFD64545',
      'icon_code': 0xe532,
    });
    await db.insert('categories', {
      'name': 'Transporte',
      'color_hex': 'FF4B6BFB',
      'icon_code': 0xe1d7,
    });
    await db.insert('categories', {
      'name': 'Hogar',
      'color_hex': 'FF00A878',
      'icon_code': 0xe318,
    });
    await db.insert('categories', {
      'name': 'Ocio',
      'color_hex': 'FFB36BFB',
      'icon_code': 0xe02c,
    });
    await db.insert('categories', {
      'name': 'Otros',
      'color_hex': 'FF7F8081',
      'icon_code': 0xe53f,
    });
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
