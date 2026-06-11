import '../models/recitation_session_model.dart';

// === Recitation Validator ===
// validates sheikh input for daily recitation
// Note: memorization at the center goes from surah 114 → 1
// within a surah, ayah numbers must increase
class RecitationValidator {
  RecitationValidator._();

  // === Helper Checks ===
  
  static bool hasAnyNewMemoField(SessionRecord s) =>
      s.newFromSurah != null ||
      s.newFromAyah != null ||
      s.newToSurah != null ||
      s.newToAyah != null;

  static bool hasCompleteNewMemo(SessionRecord s) =>
      s.newFromSurah != null &&
      s.newFromAyah != null &&
      s.newToSurah != null &&
      s.newToAyah != null;

  static bool hasAnyRevisionField(SessionRecord s) =>
      s.revFromSurah != null ||
      s.revFromAyah != null ||
      s.revToSurah != null ||
      s.revToAyah != null;

  static bool hasCompleteRevision(SessionRecord s) =>
      s.revFromSurah != null &&
      s.revFromAyah != null &&
      s.revToSurah != null &&
      s.revToAyah != null;

  // check if student is present and has a valid recitation (range + grade)
  static bool isPresentRecitation(
    SessionRecord s, {
    bool skipNewMemo = false,
    bool skipRevision = false,
  }) {
    final memo = !skipNewMemo && hasCompleteNewMemo(s);
    final rev = !skipRevision && hasCompleteRevision(s);
    return (memo || rev) && s.grade.isNotEmpty;
  }

  // === Main Validation ===

  // full validation of a session before saving to API or local DB
  static String? validatePresentSession(
    SessionRecord session,
    int? Function(int surahNumber) ayahCountForSurah, {
    bool skipNewMemo = false,
    bool skipRevision = false,
  }) {
    if (!skipNewMemo &&
        hasAnyNewMemoField(session) &&
        !hasCompleteNewMemo(session)) {
      return 'أكمل نطاق الحفظ الجديد (من سورة/آية → إلى سورة/آية)';
    }
    if (!skipRevision &&
        hasAnyRevisionField(session) &&
        !hasCompleteRevision(session)) {
      return 'أكمل نطاق المراجعة (من سورة/آية → إلى سورة/آية)';
    }

    final hasMemo = !skipNewMemo && hasCompleteNewMemo(session);
    final hasRev = !skipRevision && hasCompleteRevision(session);

    if (!hasMemo && !hasRev) {
      return 'أدخل حفظاً جديداً أو مراجعة (أو اختر «لم يسمع الاثنين»)';
    }

    if (session.grade.isEmpty) {
      return 'اختر التقدير العام للجلسة';
    }

    if (hasMemo) {
      final err = _validateRange(
        label: 'الحفظ الجديد',
        fromSurah: session.newFromSurah!,
        fromAyah: session.newFromAyah!,
        toSurah: session.newToSurah!,
        toAyah: session.newToAyah!,
        ayahCountForSurah: ayahCountForSurah,
      );
      if (err != null) return err;
    }

    if (hasRev) {
      final err = _validateRange(
        label: 'المراجعة',
        fromSurah: session.revFromSurah!,
        fromAyah: session.revFromAyah!,
        toSurah: session.revToSurah!,
        toAyah: session.revToAyah!,
        ayahCountForSurah: ayahCountForSurah,
      );
      if (err != null) return err;
    }

    return null;
  }

  // real-time validation as the sheikh is typing in the UI
  static String? liveValidateRange({
    required int? fromSurah,
    required int? fromAyah,
    required int? toSurah,
    required int? toAyah,
  }) {
    // only validate when all 4 fields are filled
    if (fromSurah == null || fromAyah == null ||
        toSurah == null || toAyah == null) {
      return null;
    }

    // reverse surah order check (must go from higher number to lower)
    if (fromSurah < toSurah) {
      return 'النطاق معكوس — لا يُسمَع تقدماً في أرقام السور';
    }

    // same surah: start ayah must be <= end ayah
    if (fromSurah == toSurah && fromAyah > toAyah) {
      return 'آية البداية يجب أن تكون أصغر من أو تساوي آية النهاية';
    }

    return null;
  }

  // internal helper for range logic
  static String? _validateRange({
    required String label,
    required int fromSurah,
    required int fromAyah,
    required int toSurah,
    required int toAyah,
    required int? Function(int surahNumber) ayahCountForSurah,
  }) {
    if (fromSurah < 1 || fromSurah > 114 || toSurah < 1 || toSurah > 114) {
      return '$label: رقم السورة غير صالح';
    }

    final fromMax = ayahCountForSurah(fromSurah);
    final toMax = ayahCountForSurah(toSurah);
    if (fromMax == null || fromMax < 1 || toMax == null || toMax < 1) {
      return '$label: تعذر التحقق من عدد الآيات';
    }

    if (fromAyah < 1 || fromAyah > fromMax) {
      return '$label: آية البداية خارج السورة';
    }
    if (toAyah < 1 || toAyah > toMax) {
      return '$label: آية النهاية خارج السورة';
    }

    if (!isForwardRange(fromSurah, fromAyah, toSurah, toAyah)) {
      return '$label: النطاق معكوس (مثال: البقرة ٢٤ → ٩ غير مسموح)';
    }

    return null;
  }

  // checks if the range follows the center's memorization order
  static bool isForwardRange(
    int fromSurah,
    int fromAyah,
    int toSurah,
    int toAyah,
  ) {
    if (fromSurah > toSurah) return true;
    if (fromSurah < toSurah) return false;
    return fromAyah <= toAyah;
  }
}
