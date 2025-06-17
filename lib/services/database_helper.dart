import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/models/health_metric.dart';
import 'package:myapp/models/metric_type.dart'; // Assuming you have this enum

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper.instance() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, 'health_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE metrics(
        id TEXT PRIMARY KEY,
        type TEXT,
        value REAL,
        date TEXT
      )
      '''
    );
  }

  Future<void> insertMetric(HealthMetric metric) async {
    final db = await database;
    await db.insert(
      'metrics',
      metric.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HealthMetric>> getMetrics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('metrics');

    return List.generate(maps.length, (i) {
      return HealthMetric.fromJson(maps[i]);
    });
  }

  // Optional: Update method
  Future<void> updateMetric(HealthMetric metric) async {
    final db = await database;
    await db.update(
      'metrics',
      metric.toJson(),
      where: 'id = ?',
      whereArgs: [metric.id],
    );
  }

  // Optional: Delete method
  Future<void> deleteMetric(String id) async {
    final db = await database;
    await db.delete(
      'metrics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}