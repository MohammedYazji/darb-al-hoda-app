class NextAyahModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final bool completed;
  final String? message;

  const NextAyahModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    this.completed = false,
    this.message,
  });

  factory NextAyahModel.fromJson(Map<String, dynamic> json) {
    if (json['completed'] == true) {
      return NextAyahModel(
        surahNumber: 0,
        surahName: '',
        ayahNumber: 0,
        completed: true,
        message: json['message'] as String?,
      );
    }

    return NextAyahModel(
      surahNumber: json['surah_number'] as int,
      surahName: json['surah_name'] as String? ?? '',
      ayahNumber: json['ayah_number'] as int,
    );
  }
}
