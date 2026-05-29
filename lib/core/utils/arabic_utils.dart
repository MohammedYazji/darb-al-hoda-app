class ArabicUtils {
  ArabicUtils._();

  // convert numbers from english to arabic
  static String toArabic(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // to handle integer directly
  static String fromInt(int number) => toArabic(number.toString());

  // to handle double directly
  static String fromDouble(int number) => toArabic(number.toString());
}
