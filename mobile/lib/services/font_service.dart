import 'package:azkar/main.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:flutter/material.dart';

class FontService {
  static const String DEFAULT_AZKAR_AND_QURAN_FONT_FAMILY = 'uthmanic';
  static const String DEFAULT_NON_AZKAR_AND_NON_QURAN_FONT_FAMILY = 'arabic';

  Future<String> getPreferredAzkarAndQuranFontFamily() async {
    var prefs = await ServiceProvider.cacheManager.getPrefs();
    String? font =
        prefs.getString(CacheManager.CACHE_KEY_AZKAR_AND_QURAN_FONT_FAMILY);
    return font ?? DEFAULT_AZKAR_AND_QURAN_FONT_FAMILY;
  }

  Future<void> setPreferredAzkarAndQuranFontFamily(
      BuildContext context, String fontFamily) async {
    var prefs = await ServiceProvider.cacheManager.getPrefs();
    await prefs.setString(
        CacheManager.CACHE_KEY_AZKAR_AND_QURAN_FONT_FAMILY, fontFamily);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (_) => false);
  }

  List<String> getAllAzkarAndQuranFontFamilyOptions() {
    return ['uthmanic', 'roboto'];
  }

  Future<String> getPreferredNonAzkarAndNonQuranFontFamily() async {
    var prefs = await ServiceProvider.cacheManager.getPrefs();
    String? font = prefs
        .getString(CacheManager.CACHE_KEY_NON_AZKAR_AND_NON_QURAN_FONT_FAMILY);
    return font ?? DEFAULT_NON_AZKAR_AND_NON_QURAN_FONT_FAMILY;
  }

  Future<void> setPreferredNonAzkarAndNonQuranFontFamily(
      BuildContext context, String fontFamily) async {
    var prefs = await ServiceProvider.cacheManager.getPrefs();
    await prefs.setString(
        CacheManager.CACHE_KEY_NON_AZKAR_AND_NON_QURAN_FONT_FAMILY, fontFamily);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (_) => false);
  }

  List<String> getAllNonAzkarAndNonQuranFontFamilyOptions() {
    return ['arabic', 'roboto'];
  }
}
