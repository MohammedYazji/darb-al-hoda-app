import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/recitation_session_model.dart';

// === Recitation Local DB ===
// SQLite helper for offline recitation logs
// Schema (single table):
//   recitation_logs(circle_id, date, student_id) — UNIQUE constraint
//   synced = 0 → pending, 1 → pushed to API
class RecitationLocalDb {
  RecitationLocalDb._();

  static Database? _db;

  // singleton getter for the database instance
  static Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  // initialize and open the database
  static Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'recitation_logs.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE recitation_logs (
            id                    INTEGER PRIMARY KEY AUTOINCREMENT,
            circle_id             INTEGER NOT NULL,
            date                  TEXT    NOT NULL,
            student_id            INTEGER NOT NULL,
            attendance_status     TEXT    NOT NULL,
            new_memo_from_surah   INTEGER,
            new_memo_from_ayah    INTEGER,
            new_memo_to_surah     INTEGER,
            new_memo_to_ayah      INTEGER,
            revision_from_surah   INTEGER,
            revision_from_ayah    INTEGER,
            revision_to_surah     INTEGER,
            revision_to_ayah      INTEGER,
            grade                 TEXT,
            synced                INTEGER NOT NULL DEFAULT 0,
            saved_at              TEXT    NOT NULL,
            UNIQUE(circle_id, date, student_id)
          )
        ''');
      },
    );
  }

  // === Write Actions ===

  // bulk-upsert all records for a specific circle and date
  // always sets synced = 0 so the sync job will push them later
  static Future<void> upsertLogs({
    required int circleId,
    required String date,
    required List<StudentRecord> records,
  }) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    final batch = database.batch();
    for (final record in records) {
      batch.insert(
        'recitation_logs',
        _toRow(circleId: circleId, date: date, record: record, savedAt: now),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // mark logs as successfully synced with the API
  static Future<void> markSynced({
    required int circleId,
    required String date,
  }) async {
    final database = await db;
    await database.update(
      'recitation_logs',
      {'synced': 1},
      where: 'circle_id = ? AND date = ?',
      whereArgs: [circleId, date],
    );
  }

  // === Read Actions ===

  // load all rows for a specific circle and date from local DB
  static Future<List<Map<String, dynamic>>> getLogsForDay({
    required int circleId,
    required String date,
  }) async {
    final database = await db;
    return database.query(
      'recitation_logs',
      where: 'circle_id = ? AND date = ?',
      whereArgs: [circleId, date],
    );
  }

  // get all unsynced rows grouped by (circle_id, date) to push them to API
  static Future<List<Map<String, dynamic>>> getPendingGroups() async {
    final database = await db;

    final pairs = await database.rawQuery('''
      SELECT DISTINCT circle_id, date
      FROM recitation_logs
      WHERE synced = 0
      ORDER BY date ASC
    ''');

    final groups = <Map<String, dynamic>>[];
    for (final pair in pairs) {
      final rows = await database.query(
        'recitation_logs',
        where: 'circle_id = ? AND date = ? AND synced = 0',
        whereArgs: [pair['circle_id'], pair['date']],
      );
      groups.add({
        'circle_id': pair['circle_id'],
        'date': pair['date'],
        'rows': rows,
      });
    }
    return groups;
  }

  // count how many days have pending logs — useful for UI indicators
  static Future<int> pendingSyncDayCount() async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT COUNT(DISTINCT date) as cnt
      FROM recitation_logs
      WHERE synced = 0
    ''');
    return (result.first['cnt'] as int?) ?? 0;
  }

  // === Helpers ===

  // convert a StudentRecord into a database row Map
  static Map<String, dynamic> _toRow({
    required int circleId,
    required String date,
    required StudentRecord record,
    required String savedAt,
  }) {
    String status;
    if (record.presentNotRecited) {
      status = 'present_not_recited';
    } else {
      status = switch (record.absence) {
        AbsenceType.absent => 'absent_unexcused',
        AbsenceType.excused => 'absent_excused',
        AbsenceType.none =>
          record.hasRecitation ? 'present' : 'present_not_recited',
      };
    }

    final s = record.session;

    return {
      'circle_id': circleId,
      'date': date,
      'student_id': record.student.id,
      'attendance_status': status,
      'new_memo_from_surah': s?.newFromSurah,
      'new_memo_from_ayah': s?.newFromAyah,
      'new_memo_to_surah': s?.newToSurah,
      'new_memo_to_ayah': s?.newToAyah,
      'revision_from_surah': s?.revFromSurah,
      'revision_from_ayah': s?.revFromAyah,
      'revision_to_surah': s?.revToSurah,
      'revision_to_ayah': s?.revToAyah,
      'grade': (s?.grade.isNotEmpty == true) ? s!.grade : null,
      'synced': 0,
      'saved_at': savedAt,
    };
  }

  // convert a local DB row back to the format expected by the API
  static Map<String, dynamic> rowToApiEntry(Map<String, dynamic> row) {
    final entry = <String, dynamic>{
      'student_id': row['student_id'],
      'attendance_status': row['attendance_status'],
    };

    if (row['attendance_status'] == 'present') {
      _addIfNotNull(entry, 'new_memo_from_surah', row['new_memo_from_surah']);
      _addIfNotNull(entry, 'new_memo_from_ayah', row['new_memo_from_ayah']);
      _addIfNotNull(entry, 'new_memo_to_surah', row['new_memo_to_surah']);
      _addIfNotNull(entry, 'new_memo_to_ayah', row['new_memo_to_ayah']);
      _addIfNotNull(entry, 'revision_from_surah', row['revision_from_surah']);
      _addIfNotNull(entry, 'revision_from_ayah', row['revision_from_ayah']);
      _addIfNotNull(entry, 'revision_to_surah', row['revision_to_surah']);
      _addIfNotNull(entry, 'revision_to_ayah', row['revision_to_ayah']);
      _addIfNotNull(entry, 'grade', row['grade']);
    }

    return entry;
  }

  static void _addIfNotNull(
    Map<String, dynamic> map,
    String key,
    dynamic value,
  ) {
    if (value != null) map[key] = value;
  }
}
