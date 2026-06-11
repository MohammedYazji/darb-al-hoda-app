// Model to represent a Surah in the Quran
class SurahModel {
  // declare the proprieties
  final int number; // surah index (1..114)
  final String name; // surah name in Arabic
  final int ayahCount; // total ayahs in this surah
  final int startPage; // page number where surah starts in Mus'haf
  final int endPage; // page number where surah ends

  // constructor
  const SurahModel({
    required this.number,
    required this.name,
    required this.ayahCount,
    required this.startPage,
    required this.endPage,
  });

  // Convert API JSON response into SurahModel object
  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'],
      name: json['name'],
      ayahCount: json['ayah_count'],
      startPage: json['start_page'],
      endPage: json['end_page'],
    );
  }
}
