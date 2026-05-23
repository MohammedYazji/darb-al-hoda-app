// This file will change the json which come from the api
// as Dart object so i can use the data in the app

class UserModel {
  // declare the proprieties
  final int id;
  final String name;
  final String email;
  final String? phone; // optional - for now
  final List<String> roles;
  final StudentModel?
  student; // if the user is a student too so store its data also

  // constructor
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.roles,
    this.student,
  });

  // take the response as json and fill the values for the userModel properties by call the constructor
  // so now i can access all the data through the userModel and i sure what the type of each one
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      roles: List<String>.from(json['roles'] ?? []), // list of roles
      student: json['student'] != null
          ? StudentModel.fromJson(json['student'])
          : null,
    );
  }

  bool hasRole(String role) => roles.contains(role);

  bool get isAdmin => hasRole('admin');
  bool get isCircleSheikh => hasRole('circle_sheikh');
  bool get isStudent => hasRole('student');

  // so after the user login and based on
  bool get hasMultipleRoles => roles.length > 1;
}

class StudentModel {
  // declare the proprieties
  final int id;
  final String circle;
  final String gradeLevel;
  final int memorized;
  final int confirmed;

  // constructor
  const StudentModel({
    required this.id,
    required this.circle,
    required this.gradeLevel,
    required this.memorized,
    required this.confirmed,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      circle: json['circle'] ?? '',
      gradeLevel: json['grade_level'] ?? '',
      memorized: json['memorized'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
    );
  }
}
