import 'package:darb_al_hoda_app/core/models/circle_model.dart';
import 'package:darb_al_hoda_app/core/models/next_ayah_model.dart';
import 'package:darb_al_hoda_app/core/models/recitation_log_model.dart';
import 'package:darb_al_hoda_app/core/models/recitation_session_model.dart';
import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:darb_al_hoda_app/core/utils/recitation_validator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecitationState {
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const RecitationState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  RecitationState copyWith({bool? isLoading, bool? isSaving, String? error}) {
    return RecitationState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class RecitationNotifier extends StateNotifier<RecitationState> {
  final Dio _dio;

  RecitationNotifier()
    : _dio = DioClient.instance,
      super(const RecitationState());

  // === Date helpers ===

  /// Saturday of the current week + [dayIndex] (0=Sat … 4=Wed).
  static DateTime dateTimeForDayIndex(int dayIndex) {
    return _saturdayOfWeek(DateTime.now()).add(Duration(days: dayIndex));
  }

  static String dateForDayIndex(int dayIndex) =>
      _formatDate(dateTimeForDayIndex(dayIndex));

  /// 0=Sat … 4=Wed; Thu/Fri default to Saturday (0).
  static int todayDayIndex() {
    final now = DateTime.now();
    final saturday = _saturdayOfWeek(now);
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(saturday.year, saturday.month, saturday.day)).inDays;
    if (diff >= 0 && diff <= 4) return diff;
    return 0;
  }

  static DateTime _saturdayOfWeek(DateTime reference) {
    var saturday = DateTime(reference.year, reference.month, reference.day);
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.subtract(const Duration(days: 1));
    }
    return saturday;
  }

  static String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  // === Next-ayah suggestion ===

  Future<NextAyahModel?> fetchNextAyah(int studentId) async {
    try {
      final response = await _dio.get(
        '/quran/next-ayah',
        queryParameters: {'student_id': studentId},
      );
      return NextAyahModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException {
      return null;
    }
  }

  /// Suggest where new memorization should start when this day has no saved log yet.
  Future<List<StudentRecord>> applyNextAyahSuggestions(
    List<StudentRecord> records,
  ) async {
    final updated = <StudentRecord>[];

    for (final record in records) {
      if (record.hasRecitation ||
          record.absence != AbsenceType.none ||
          record.hasSuggestion ||
          record.skipNewMemo ||
          record.presentNotRecited) {
        updated.add(record);
        continue;
      }

      final next = await fetchNextAyah(record.student.id);
      if (next == null || next.completed) {
        updated.add(record);
        continue;
      }

      updated.add(
        StudentRecord(
          student: record.student,
          absence: record.absence,
          isSuggestion: true,
          session: SessionRecord(
            newFromSurah: next.surahNumber,
            newFromAyah: next.ayahNumber,
          ),
        ),
      );
    }

    return updated;
  }

  // === Fetch ===

  Future<List<RecitationLogModel>> fetchLogs({
    required int circleId,
    required String date,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get(
        '/recitation-logs',
        queryParameters: {'circle_id': circleId, 'date': date},
      );

      final logs = (response.data['logs'] as List)
          .map((e) => RecitationLogModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(isLoading: false);
      return logs;
    } on DioException {
      final message = 'لا يوجد اتصال · تعذر تحميل سجل التسميع';
      state = state.copyWith(isLoading: false, error: message);
      rethrow;
    }
  }

  // === Save ===─

  Future<String> saveLogs({
    required int circleId,
    required String date,
    required List<StudentRecord> records,
    required int? Function(int surahNumber) ayahCountForSurah,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final toSave = records
          .where(
            (r) =>
                r.absence != AbsenceType.none ||
                r.hasRecitation ||
                r.presentNotRecited,
          )
          .toList();

      for (final record in toSave) {
        if (record.hasRecitation && record.session != null) {
          final err = RecitationValidator.validatePresentSession(
            record.session!,
            ayahCountForSurah,
            skipNewMemo: record.skipNewMemo,
            skipRevision: record.skipRevision,
          );
          if (err != null) {
            state = state.copyWith(isSaving: false);
            throw Exception('${record.student.name}: $err');
          }
        }
      }

      if (toSave.isEmpty) {
        state = state.copyWith(isSaving: false);
        throw Exception('لا يوجد بيانات للحفظ');
      }

      final logsPayload = toSave.map(_logEntryFromRecord).toList();
      await _dio.post(
        '/recitation-logs',
        data: {'circle_id': circleId, 'date': date, 'logs': logsPayload},
      );

      state = state.copyWith(isSaving: false);
      return 'تم تسجيل التسميع بنجاح';
    } on DioException catch (e) {
      state = state.copyWith(isSaving: false);
      final msg = e.response?.data?['message'] as String?;
      if (msg != null) throw Exception(msg);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  // === Merge & helpers ===─

  static List<StudentRecord> mergeStudentsWithLogs(
    List<CircleStudentModel> students,
    List<RecitationLogModel> logs,
  ) {
    final logByStudent = {for (final log in logs) log.student.id: log};

    return students.map((student) {
      final log = logByStudent[student.id];
      if (log == null) return StudentRecord(student: student);
      return _studentRecordFromLog(student, log);
    }).toList();
  }

  static StudentRecord _studentRecordFromLog(
    CircleStudentModel student,
    RecitationLogModel log,
  ) {
    final absence = switch (log.attendanceStatus) {
      'absent_unexcused' => AbsenceType.absent,
      'absent_excused' => AbsenceType.excused,
      _ => AbsenceType.none,
    };

    SessionRecord? session;
    if (log.attendanceStatus == 'present') {
      final nm = log.newMemorization;
      final rev = log.revision;
      final candidate = SessionRecord(
        newFromSurah: nm?.fromSurah,
        newFromAyah: nm?.fromAyah,
        newToSurah: nm?.toSurah,
        newToAyah: nm?.toAyah,
        revFromSurah: rev?.fromSurah,
        revFromAyah: rev?.fromAyah,
        revToSurah: rev?.toSurah,
        revToAyah: rev?.toAyah,
        grade: log.grade ?? '',
      );
      if (candidate.hasData) session = candidate;
    }

    return StudentRecord(
      student: student,
      session: session,
      absence: absence,
      isSuggestion: false,
    );
  }

  static Map<String, dynamic> _logEntryFromRecord(StudentRecord record) {
    if (record.presentNotRecited) {
      return {
        'student_id': record.student.id,
        'attendance_status': 'present_not_recited',
      };
    }

    final status = switch (record.absence) {
      AbsenceType.absent => 'absent_unexcused',
      AbsenceType.excused => 'absent_excused',
      AbsenceType.none =>
        record.hasRecitation ? 'present' : 'present_not_recited',
    };

    final entry = <String, dynamic>{
      'student_id': record.student.id,
      'attendance_status': status,
    };

    if (status == 'present' && record.hasRecitation) {
      final s = record.session!;
      void addRange(String prefix, int? fromS, int? fromA, int? toS, int? toA) {
        if (fromS != null) entry['${prefix}_from_surah'] = fromS;
        if (fromA != null) entry['${prefix}_from_ayah'] = fromA;
        if (toS != null) entry['${prefix}_to_surah'] = toS;
        if (toA != null) entry['${prefix}_to_ayah'] = toA;
      }

      addRange(
        'new_memo',
        s.newFromSurah,
        s.newFromAyah,
        s.newToSurah,
        s.newToAyah,
      );
      addRange(
        'revision',
        s.revFromSurah,
        s.revFromAyah,
        s.revToSurah,
        s.revToAyah,
      );

      if (s.grade.isNotEmpty) entry['grade'] = s.grade;
    }

    return entry;
  }
}

final recitationProvider =
    StateNotifierProvider<RecitationNotifier, RecitationState>((ref) {
      return RecitationNotifier();
    });
