class NominationModel {
  // declare the proprieties
  final int id;
  final String type; // individual, collective
  final String
  status; // pending_recitation, recitation_approved, passed, failed
  final bool isPending; // is still under process?
  final int? juzNumber; // optional - just for the individual
  final List<int>? juzNumbers; // optional - just for collective
  final NominationStudentModel student; // nominated student
  final NominationUserModel nominatedBy; // who nominate it
  final RecitationInfoModel? recitation; // recitation result
  final ExamInfoModel? exam; // exam result
  final String createdAt; // when this nomination created

  // constructor
  const NominationModel({
    required this.id,
    required this.type,
    required this.status,
    required this.isPending,
    this.juzNumber,
    this.juzNumbers,
    required this.student,
    required this.nominatedBy,
    this.recitation,
    this.exam,
    required this.createdAt,
  });

  // convert the json response into Object of NominationModel
  factory NominationModel.fromJson(Map<String, dynamic> json) {
    return NominationModel(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      isPending: json['is_pending'] ?? false,
      juzNumber: json['juz_number'],
      juzNumbers: json['juz_numbers'] != null
          ? List<int>.from(json['juz_numbers'])
          : null, // list of numbers
      // as nested objects
      student: NominationStudentModel.fromJson(json['student']),
      nominatedBy: NominationUserModel.fromJson(json['nominated_by']),

      recitation: json['recitation'] != null
          ? RecitationInfoModel.fromJson(json['recitation'])
          : null,
      exam: json['exam'] != null ? ExamInfoModel.fromJson(json['exam']) : null,
      createdAt: json['created_at'] ?? '',
    );
  }

  // Helper methods
  bool get isIndividual => type == 'individual';
  bool get isCollective => type == 'collective';
  bool get isPassed => status == 'passed';
  bool get isFailed => status == 'failed';
  bool get needsRecitation =>
      status == 'pending_recitation'; // still waiting the recitation sheikh
  bool get needsExam =>
      status == 'pending_exam' ||
      status == 'recitation_approved'; // recitation done and waiting for exam
}

class NominationStudentModel {
  // declare the proprieties
  final int id;
  final String name; // json['user']['name'] — nested from json
  final String circle; // json['circle']['name'] — nested from json

  // constructor
  const NominationStudentModel({
    required this.id,
    required this.name,
    required this.circle,
  });

  factory NominationStudentModel.fromJson(Map<String, dynamic> json) {
    return NominationStudentModel(
      id: json['id'],
      name: json['user']?['name'] ?? '',
      circle: json['circle']?['name'] ?? '',
    );
  }
}

class NominationUserModel {
  // declare the properties
  final int id;
  final String name;

  // constructor
  const NominationUserModel({required this.id, required this.name});

  factory NominationUserModel.fromJson(Map<String, dynamic> json) {
    return NominationUserModel(id: json['id'], name: json['name']);
  }
}

class RecitationInfoModel {
  final String? sheikhName; // name of sheikh
  final int? score; // score of recitation 0-100
  final String? at; // when the recitation done
  final String? notes; // notes of the sheikh

  const RecitationInfoModel({this.sheikhName, this.score, this.at, this.notes});

  factory RecitationInfoModel.fromJson(Map<String, dynamic> json) {
    return RecitationInfoModel(
      sheikhName: json['sheikh']?['name'],
      score: json['score'],
      at: json['at'],
      notes: json['notes'],
    );
  }
}

class ExamInfoModel {
  final String? sheikhName; // sheikh will make the exam
  final int? score; // score of the exam 0-100
  final String? at; // when the exam done
  final String? notes; // notes of the sheikh

  const ExamInfoModel({this.sheikhName, this.score, this.at, this.notes});

  factory ExamInfoModel.fromJson(Map<String, dynamic> json) {
    return ExamInfoModel(
      sheikhName: json['sheikh']?['name'],
      score: json['score'],
      at: json['at'],
      notes: json['notes'],
    );
  }
}
