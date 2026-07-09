import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'urban_report.dart';

class ReportRepository {
  ReportRepository._();

  static const _databaseName = 'voz_urbana.db';
  static const _databaseVersion = 1;
  static const _reportsTable = 'reports';

  static Database? _database;

  static Future<Database> get _db async {
    final existingDatabase = _database;
    if (existingDatabase != null) return existingDatabase;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_reportsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            image_path TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    _database = database;
    return database;
  }

  static Future<int> save(UrbanReport report) async {
    final db = await _db;

    return db.insert(
      _reportsTable,
      report.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<UrbanReport>> findAll() async {
    final db = await _db;

    final rows = await db.query(
      _reportsTable,
      orderBy: 'datetime(created_at) DESC',
    );

    return rows.map(UrbanReport.fromMap).toList();
  }
}
