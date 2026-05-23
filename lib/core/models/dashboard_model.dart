class DashboardModel {
  final DashboardStudentModel student; // student info
  final RankingModel ranking; // ranking on circle and the center
  final CompetitorModel? closestCompetitor; // optional - null if the first
  final StarModel? starOfMonth; // star of circle and the center
  final AttendanceStatsModel attendanceThisMonth; // attendance statistics

  const DashboardModel({
    required this.student,
    required this.ranking,
    this.closestCompetitor,
    this.starOfMonth,
    required this.attendanceThisMonth,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      student: DashboardStudentModel.fromJson(json['student']),
      ranking: RankingModel.fromJson(json['ranking']),

      // optional
      closestCompetitor: json['closest_competitor'] != null
          ? CompetitorModel.fromJson(json['closest_competitor'])
          : null,
      starOfMonth: json['star_of_month'] != null
          ? StarModel.fromJson(json['star_of_month'])
          : null,

      attendanceThisMonth: AttendanceStatsModel.fromJson(
        json['attendance_this_month'],
      ),
    );
  }
}

// student info in the dashboard
class DashboardStudentModel {
  final int id;
  final String name;
  final String circle; // circle name of the student
  final int memorized; // how many juz student memorized
  final int confirmed; // how many juz student confirmed well

  // constructor
  const DashboardStudentModel({
    required this.id,
    required this.name,
    required this.circle,
    required this.memorized,
    required this.confirmed,
  });

  factory DashboardStudentModel.fromJson(Map<String, dynamic> json) {
    return DashboardStudentModel(
      id: json['id'],
      name: json['name'] ?? '',
      circle: json['circle'] ?? '',
      memorized: json['memorized'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
    );
  }

  // percentage of progress
  double get progressPercentage => memorized / 30;
}

// Rankings
class RankingModel {
  final int center; // ranking of student - whole center
  final int circle; // ranking of student - his circle

  const RankingModel({required this.center, required this.circle});

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      center: json['center'] ?? 0,
      circle: json['circle'] ?? 0,
    );
  }
}

// the closest competitor
class CompetitorModel {
  final String name; // the competitor name
  final int memorized; // how many juz the competitor memorized
  final int gap; // gap between the current student and the competitor

  const CompetitorModel({
    required this.name,
    required this.memorized,
    required this.gap,
  });

  factory CompetitorModel.fromJson(Map<String, dynamic> json) {
    return CompetitorModel(
      name: json['name'] ?? '',
      memorized: json['memorized'] ?? 0,
      gap: json['gap'] ?? 0,
    );
  }
}

// Star of the month
class StarModel {
  final int id;
  final String name;

  const StarModel({required this.id, required this.name});

  factory StarModel.fromJson(Map<String, dynamic> json) {
    return StarModel(id: json['id'], name: json['name'] ?? '');
  }
}

// Attendance Statistics
class AttendanceStatsModel {
  final int present; // حضر
  final int absent; // غاب
  final int excused; // معذور
  final int total; // الإجمالي

  const AttendanceStatsModel({
    required this.present,
    required this.absent,
    required this.excused,
    required this.total,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsModel(
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      excused: json['excused'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  // attendance percentage i think will be useful for Progress Bar
  double get percentage => total == 0 ? 0 : present / total;
}
