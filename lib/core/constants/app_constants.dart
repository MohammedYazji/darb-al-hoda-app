import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  //private we can't make instance from this class just access static methods and proprieties
  AppConstants._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    return Platform.isAndroid
        ? 'http://10.0.2.2:8000/api/v1'
        : 'http://127.0.0.1:8000/api/v1';
  }

  // === Storage Keys ===
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const String activeRoleKey = 'active_role';

  // === Roles ===
  static const String roleAdmin = 'admin';
  static const String roleCircleSheikh = 'circle_sheikh';
  static const String roleRecitationSheikh = 'recitation_sheikh';
  static const String roleIndividualExamSheikh = 'individual_exam_sheikh';
  static const String roleCollectiveExamSheikh = 'collective_exam_sheikh';
  static const String roleStudent = 'student';

  // === Grade Levels ===
  static const Map<String, String> gradeLevels = {
    'grade_3': 'الصف الثالث',
    'grade_4': 'الصف الرابع',
    'grade_5': 'الصف الخامس',
    'grade_6': 'الصف السادس',
    'grade_7': 'الصف السابع',
    'grade_8': 'الصف الثامن',
    'grade_9': 'الصف التاسع',
    'grade_10': 'الصف العاشر',
    'grade_11': 'الصف الحادي عشر',
    'grade_12': 'الصف الثاني عشر',
    'university': 'جامعي',
    'graduated': 'خريح',
  };

  // === Attendance Status ===
  static const Map<String, String> attendanceStatus = {
    'present': 'حضر وسمّع',
    'present_not_recited': 'حضر ولم يسمّع',
    'absent_excused': 'غائب بعذر',
    'absent_unexcused': 'غائب بدون عذر',
  };

  // === Juz Numbers ===
  static const Map<int, String> juzNames = {
    1: 'الجزء الأول',
    2: 'الجزء الثاني',
    3: 'الجزء الثالث',
    4: 'الجزء الرابع',
    5: 'الجزء الخامس',
    6: 'الجزء السادس',
    7: 'الجزء السابع',
    8: 'الجزء الثامن',
    9: 'الجزء التاسع',
    10: 'الجزء العاشر',
    11: 'الجزء الحادي عشر',
    12: 'الجزء الثاني عشر',
    13: 'الجزء الثالث عشر',
    14: 'الجزء الرابع عشر',
    15: 'الجزء الخامس عشر',
    16: 'الجزء السادس عشر',
    17: 'الجزء السابع عشر',
    18: 'الجزء الثامن عشر',
    19: 'الجزء التاسع عشر',
    20: 'الجزء العشرون',
    21: 'الجزء الحادي والعشرون',
    22: 'الجزء الثاني والعشرون',
    23: 'الجزء الثالث والعشرون',
    24: 'الجزء الرابع والعشرون',
    25: 'الجزء الخامس والعشرون',
    26: 'الجزء السادس والعشرون',
    27: 'الجزء السابع والعشرون',
    28: 'الجزء الثامن والعشرون',
    29: 'الجزء التاسع والعشرون',
    30: 'الجزء الثلاثون',
  };
}
