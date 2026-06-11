import 'circle_model.dart';
import '../utils/recitation_validator.dart';

// === Session Record ===
// data of recitation for one student on a specific date
class SessionRecord {
  // declare the proprieties
  final int? newFromSurah;
  final int? newFromAyah;
  final int? newToSurah;
  final int? newToAyah;
  final double? newPages;
  final int? revFromSurah;
  final int? revFromAyah;
  final int? revToSurah;
  final int? revToAyah;
  final double? revPages;
  final String grade;

  // constructor
  const SessionRecord({
    this.newFromSurah,
    this.newFromAyah,
    this.newToSurah,
    this.newToAyah,
    this.newPages,
    this.revFromSurah,
    this.revFromAyah,
    this.revToSurah,
    this.revToAyah,
    this.revPages,
    this.grade = '',
  });

  // copy with helper to update specific fields
  SessionRecord copyWith({
    int? newFromSurah,
    int? newFromAyah,
    int? newToSurah,
    int? newToAyah,
    double? newPages,
    int? revFromSurah,
    int? revFromAyah,
    int? revToSurah,
    int? revToAyah,
    double? revPages,
    String? grade,
  }) {
    return SessionRecord(
      newFromSurah: newFromSurah ?? this.newFromSurah,
      newFromAyah: newFromAyah ?? this.newFromAyah,
      newToSurah: newToSurah ?? this.newToSurah,
      newToAyah: newToAyah ?? this.newToAyah,
      newPages: newPages ?? this.newPages,
      revFromSurah: revFromSurah ?? this.revFromSurah,
      revFromAyah: revFromAyah ?? this.revFromAyah,
      revToSurah: revToSurah ?? this.revToSurah,
      revToAyah: revToAyah ?? this.revToAyah,
      revPages: revPages ?? this.revPages,
      grade: grade ?? this.grade,
    );
  }

  // check if any data has been entered
  bool get hasData {
    return newFromSurah != null ||
        newFromAyah != null ||
        newToSurah != null ||
        newToAyah != null ||
        revFromSurah != null ||
        revFromAyah != null ||
        revToSurah != null ||
        revToAyah != null ||
        grade.isNotEmpty;
  }

  // helper to clear new memorization fields
  SessionRecord withoutNewMemo() {
    return SessionRecord(
      revFromSurah: revFromSurah,
      revFromAyah: revFromAyah,
      revToSurah: revToSurah,
      revToAyah: revToAyah,
      grade: grade,
    );
  }

  // helper to clear revision fields
  SessionRecord withoutRevision() {
    return SessionRecord(
      newFromSurah: newFromSurah,
      newFromAyah: newFromAyah,
      newToSurah: newToSurah,
      newToAyah: newToAyah,
      grade: grade,
    );
  }
}

// === Absence Type ===
// status of student attendance for the session
enum AbsenceType {
  none,
  absent, // without excuse
  excused, // with official excuse
}

// === Student Record ===
// links the student info with their session record and attendance status
class StudentRecord {
  final CircleStudentModel student;
  SessionRecord? session;
  AbsenceType absence;

  // pre-filled from API as a suggestion (not saved yet)
  bool isSuggestion;

  bool skipNewMemo;
  bool skipRevision;

  // present but did not recite anything
  bool presentNotRecited;

  // constructor
  StudentRecord({
    required this.student,
    this.session,
    this.absence = AbsenceType.none,
    this.isSuggestion = false,
    this.skipNewMemo = false,
    this.skipRevision = false,
    this.presentNotRecited = false,
  });

  // helper to check if this student has a valid recitation to save
  bool get hasRecitation =>
      !isSuggestion &&
      !presentNotRecited &&
      session != null &&
      RecitationValidator.isPresentRecitation(
        session!,
        skipNewMemo: skipNewMemo,
        skipRevision: skipRevision,
      );

  // check if we have a suggestion ready
  bool get hasSuggestion =>
      isSuggestion && session != null && session!.hasData;
}
