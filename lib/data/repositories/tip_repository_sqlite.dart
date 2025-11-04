import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:greenwise/data/models/eco_tip.dart';
import 'package:greenwise/data/models/streak.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'tip_repository.dart';

class Tip {
  final int id;
  final String text;
  final String category;
  final String createdAt;
  final String? why;
  final String? source; // source attribution
  final bool isActive;

  Tip({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
    this.why,
    this.source,
    this.isActive = true,
  });

  factory Tip.fromMap(Map<String, dynamic> map) => Tip(
    id: map['id'],
    text: map['text'],
    category: map['category'],
    createdAt: map['createdAt'],
    why: map['why'],
    source: map['source'],
    isActive: map['isActive'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'category': category,
    'createdAt': createdAt,
    'why': why,
    'source': source,
    'isActive': isActive ? 1 : 0,
  };
}


class TipRepositorySqlite implements TipRepository {
  // Call this after database is initialized
  Future<void> populateIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tips')) ?? 0;
    if (count == 0) {
      // Load tips from assets/data/tips.json
      final raw = await rootBundle.loadString('assets/data/tips.json');
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
      for (final m in jsonList) {
        await db.insert('tips', {
          'id': null,
          'text': m['text'],
          'category': m['category'],
          'createdAt': m['createdAt'],
          'why': m['explanation'],
          'source': m['source'],
          'isActive': 1,
        });
      }
    }
  }
  @override
  Future<EcoTip> getDailyTip(DateTime date) async {
    final tips = await getAllTips();
    if (tips.isEmpty) throw Exception('No tips in database');
    final startOfYear = DateTime(date.year, 1, 1);
    final idx = date.difference(startOfYear).inDays % tips.length;
    final tip = tips[idx];
    // Convert Tip to EcoTip
    return EcoTip(
      id: tip.id.toString(),
      text: tip.text,
      category: EcoTipCategory.values.firstWhere((c) => c.name == tip.category),
      explanation: tip.why,
      createdAt: DateTime.parse(tip.createdAt),
      source: tip.source,
    );
  }

  @override
  Future<void> markCompleted(DateTime date) async {
    // You can use SharedPreferences as before, or migrate to SQLite for completions
    // For now, keep SharedPreferences logic for streaks/completions
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_tip_${date.toIso8601String().substring(0, 10)}';
    await prefs.setBool(key, true);
  }

  @override
  Future<StreakState> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('streak_state_v1');
    if (raw == null) return StreakState.empty;
    try {
      return StreakState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return StreakState.empty;
    }
  }

  @override
  Future<Map<DateTime, bool>> getCompletions(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final Map<DateTime, bool> result = {};
    for (int i = 0; i < days; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = 'completed_tip_${day.toIso8601String().substring(0, 10)}';
      result[day] = prefs.getBool(key) ?? false;
    }
    return result;
  }

  @override
  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('streak_state_v1');
    final now = DateTime.now();
    for (int i = 0; i < 500; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = 'completed_tip_${day.toIso8601String().substring(0, 10)}';
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'greenwise_tips.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tips (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              text TEXT NOT NULL,
              category TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              why TEXT,
              source TEXT,
              isActive INTEGER DEFAULT 1
            )
          ''');
        },
      );
    } catch (e) {
      // If database initialization fails (e.g., in DevicePreview on desktop),
      // throw a more informative error
      throw Exception('Database initialization failed: $e\n'
          'If using DevicePreview, this is a known limitation. '
          'The app works normally when run directly on a device/emulator.');
    }
  }

  Future<List<Tip>> getAllTips() async {
    final db = await database;
    final maps = await db.query('tips', where: 'isActive = 1');
    return maps.map((m) => Tip.fromMap(m)).toList();
  }

  Future<void> insertTip(Tip tip) async {
    final db = await database;
    await db.insert('tips', tip.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTip(Tip tip) async {
    final db = await database;
    await db.update('tips', tip.toMap(), where: 'id = ?', whereArgs: [tip.id]);
  }

  Future<void> deleteTip(int id) async {
    final db = await database;
    await db.update('tips', {'isActive': 0}, where: 'id = ?', whereArgs: [id]);
  }
}
