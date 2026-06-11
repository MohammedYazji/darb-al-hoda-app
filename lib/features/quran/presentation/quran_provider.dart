import 'package:darb_al_hoda_app/core/models/surah_model.dart';
import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// === State ===
// stores the list of surahs and loading/error status
class QuranState {
  final List<SurahModel> surahs;
  final bool isLoading;
  final String? error;

  const QuranState({
    this.surahs = const [],
    this.isLoading = false,
    this.error,
  });

  // helper to check if we already have data
  bool get hasData => surahs.isNotEmpty;

  QuranState copyWith({
    List<SurahModel>? surahs,
    bool? isLoading,
    String? error,
  }) {
    return QuranState(
      surahs: surahs ?? this.surahs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// === Notifier ===
// handles fetching Quran data from the API
class QuranNotifier extends StateNotifier<QuranState> {
  final Dio _dio;

  QuranNotifier() : _dio = DioClient.instance, super(const QuranState());

  // === Fetch Surahs ===
  // retrieves the full list of surahs from the API
  Future<void> fetchSurahs() async {
    // skip if we already fetched it
    if (state.hasData) return;

    // 1. update the state to loading
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 2. send the request to the api
      final response = await _dio.get('/quran/surahs');

      // 3. convert JSON list into SurahModel objects
      final List<SurahModel> surahs = (response.data['data'] as List)
          .map((s) => SurahModel.fromJson(s))
          .toList();

      // 4. update the state with fetched data
      state = state.copyWith(surahs: surahs, isLoading: false);
    } catch (e) {
      // 5. handle errors
      state = state.copyWith(isLoading: false, error: 'فشل تحميل السور');
    }
  }

  // === Helpers ===

  // get specific surah info by its number
  SurahModel? getSurah(int number) {
    try {
      return state.surahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  // get how many ayahs in a surah — useful for validation
  int getAyahCount(int surahNumber) {
    return getSurah(surahNumber)?.ayahCount ?? 0;
  }
}

// === Provider ===
final quranProvider = StateNotifierProvider<QuranNotifier, QuranState>((ref) {
  return QuranNotifier();
});
