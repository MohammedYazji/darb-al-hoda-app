class CircleModel {
  // declare the proprieties
  final int id;
  final String name;
  final bool isActive;
  final SheikhModel mainSheikh;
  final SheikhModel? assistantSheikh; // I think must be optional
  final int? studentsCount;

  // constructor
  const CircleModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.mainSheikh,
    this.assistantSheikh,
    this.studentsCount,
  });

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'] ?? true,
      mainSheikh: SheikhModel.fromJson(json['main_sheikh']),
      assistantSheikh: json['assistant_sheikh'] != null
          ? SheikhModel.fromJson(json['assistant_sheikh'])
          : null,
      studentsCount: json['students_count'],
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
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
