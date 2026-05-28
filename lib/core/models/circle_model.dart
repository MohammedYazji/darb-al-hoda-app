class CircleModel {
  // declare the proprieties
  final int id;
  final String name;
  final bool isActive;
  final SheikhModel mainSheikh;
  final SheikhModel? assistantSheikh; // I think must be optional
  final int? studentsCount;
  final List<CircleStudentModel> students;

  // constructor
  const CircleModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.mainSheikh,
    this.assistantSheikh,
    this.studentsCount,
    this.students = const [],
  });

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['id'] ?? 0,
      name: json['name'],
      isActive: json['is_active'] ?? true,
      mainSheikh: SheikhModel.fromJson(json['main_sheikh']),
      assistantSheikh: json['assistant_sheikh'] != null
          ? SheikhModel.fromJson(json['assistant_sheikh'])
          : null,
      studentsCount: json['students_count'],
      students: json['students'] != null
          ? (json['students'] as List)
                .map((s) => CircleStudentModel.fromJson(s))
                .toList()
          : [],
    );
  }
}

class SheikhModel {
  // declare the proprieties
  final int id;
  final String name;
  final String? phone;
  final List<String> roles;

  // constructor
  const SheikhModel({
    required this.id,
    required this.name,
    this.phone,
    required this.roles,
  });

  factory SheikhModel.fromJson(Map<String, dynamic> json) {
    return SheikhModel(
      id: json['id'] ?? 0,
      name: json['name'],
      phone: json['phone'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}

class CircleStudentModel {
  final int id;
  final String name;
  final String gradeLevel;
  final int memorized;
  final int confirmed;
  final bool isActive;

  const CircleStudentModel({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.memorized,
    required this.confirmed,
    required this.isActive,
  });

  factory CircleStudentModel.fromJson(Map<String, dynamic> json) {
    return CircleStudentModel(
      id: json['id'] ?? 0,
      name: json['user']?['name'] ?? '',
      gradeLevel: json['grade_level'] ?? '',
      memorized: json['memorized'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}
