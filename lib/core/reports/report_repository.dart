import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'urban_report.dart';

class ReportRepository {
  ReportRepository._();

  static const _databaseName = 'voz_urbana.db';
  static const _databaseVersion = 1;
  static const _reportsTable = 'reports';
  static const _webReportsKey = 'voz_urbana_reports';

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
    if (kIsWeb) return _saveOnWeb(report);

    final db = await _db;

    return db.insert(
      _reportsTable,
      report.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<UrbanReport>> findAll() async {
    if (kIsWeb) return _findAllOnWeb();

    final db = await _db;

    final rows = await db.query(
      _reportsTable,
      orderBy: 'datetime(created_at) DESC',
    );

    return rows.map(UrbanReport.fromMap).toList();
  }

  static Future<void> deleteById(int id) async {
    if (kIsWeb) {
      final reports = await _findAllOnWeb();
      reports.removeWhere((report) => report.id == id);
      await _persistWebReports(reports);
      return;
    }

    final db = await _db;

    await db.delete(
      _reportsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateStatus({
    required int id,
    required String status,
  }) async {
    if (kIsWeb) {
      final reports = await _findAllOnWeb();
      final updatedReports = reports.map((report) {
        if (report.id != id) return report;

        return UrbanReport(
          id: report.id,
          category: report.category,
          description: report.description,
          imagePath: report.imagePath,
          latitude: report.latitude,
          longitude: report.longitude,
          status: status,
          createdAt: report.createdAt,
        );
      }).toList();

      await _persistWebReports(updatedReports);
      return;
    }

    final db = await _db;

    await db.update(
      _reportsTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> _saveOnWeb(UrbanReport report) async {
    final reports = await _findAllOnWeb();
    final nextId = _nextWebId(reports);
    final savedReport = UrbanReport(
      id: nextId,
      category: report.category,
      description: report.description,
      imagePath: report.imagePath,
      latitude: report.latitude,
      longitude: report.longitude,
      status: report.status,
      createdAt: report.createdAt,
    );

    reports.insert(0, savedReport);
    await _persistWebReports(reports);

    return nextId;
  }

  static Future<List<UrbanReport>> _findAllOnWeb() async {
    final preferences = await SharedPreferences.getInstance();
    final reportsJson = preferences.getStringList(_webReportsKey) ?? [];

    final reports = reportsJson
        .map((reportJson) => UrbanReport.fromMap(jsonDecode(reportJson)))
        .toList();

    reports
        .sort((first, second) => second.createdAt.compareTo(first.createdAt));

    return reports;
  }

  static Future<void> _persistWebReports(List<UrbanReport> reports) async {
    final preferences = await SharedPreferences.getInstance();
    final reportsJson = reports
        .map((report) => jsonEncode(report.toMap()))
        .toList(growable: false);

    await preferences.setStringList(_webReportsKey, reportsJson);
  }

  static int _nextWebId(List<UrbanReport> reports) {
    if (reports.isEmpty) return 1;

    final ids = reports.map((report) => report.id ?? 0);

    return ids.reduce((maxId, id) => id > maxId ? id : maxId) + 1;
  }
}
