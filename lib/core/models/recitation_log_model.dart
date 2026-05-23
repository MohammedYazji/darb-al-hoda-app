// daily recitation for each student

class RecitationLogModel {
  // declare the properties
  final int id;
  final String date; // the recitation day
  final String attendanceStatus;
  final String attendanceLabel; // status in arabic (i handle this in constants)
  final RecitationStudentModel student; // student info
  final String?
  recordedBy; // sheikh of circle who will record the daily recitation

  // optional - may  the student absent or don't recited
  final MemorizationRangeModel? newMemorization;
  final MemorizationRangeModel? revision;

  // constructor
  const RecitationLogModel({
    required this.id,
    required this.date,
    required this.attendanceStatus,
    required this.attendanceLabel,
    required this.student,
    this.recordedBy,
    this.newMemorization,
    this.revision,
  });

  factory RecitationLogModel.fromJson(Map<String, dynamic> json) {
    return RecitationLogModel(
      id: json['id'],
      date: json['date'] ?? '',
      attendanceStatus: json['attendance_status'] ?? '',
      attendanceLabel: json['attendance_label'] ?? '',
      student: RecitationStudentModel.fromJson(json['student']),
      recordedBy: json['recorded_by'],

      // new_memorization — optional
      newMemorization: json['new_memorization'] != null
          ? MemorizationRangeModel.fromJson(json['new_memorization'])
          : null,

      // revision — optional
      revision: json['revision'] != null
          ? MemorizationRangeModel.fromJson(json['revision'])
          : null,
    );
  }

  // Helper methods
  bool get isPresent =>
      attendanceStatus == 'present' ||
      attendanceStatus == 'present_not_recited';
  bool get hasNewMemorization => newMemorization != null;
  bool get hasRevision => revision != null;
}

// Student info in the daily recitation records
class RecitationStudentModel {
  // we just need the id and the name
  final int id;
  final String name;

  const RecitationStudentModel({required this.id, required this.name});

  factory RecitationStudentModel.fromJson(Map<String, dynamic> json) {
    return RecitationStudentModel(id: json['id'], name: json['name'] ?? '');
  }
}

// range of the revision and the new memorization
// one for both revision and new memo
class MemorizationRangeModel {
  final String fromSurah;
  final int fromAyah;
  final String toSurah;
  final int toAyah;

  const MemorizationRangeModel({
    required this.fromSurah,
    required this.fromAyah,
    required this.toSurah,
    required this.toAyah,
  });

  factory MemorizationRangeModel.fromJson(Map<String, dynamic> json) {
    return MemorizationRangeModel(
      fromSurah: json['from_surah'] ?? '',
      fromAyah: json['from_ayah'] ?? 0,
      toSurah: json['to_surah'] ?? '',
      toAyah: json['to_ayah'] ?? 0,
    );
  }

  // short way for clean UI
  // like "الكهف 1 - الكهف"
  String get displayText => '$fromSurah $fromAyah — $toSurah $toAyah';
}
