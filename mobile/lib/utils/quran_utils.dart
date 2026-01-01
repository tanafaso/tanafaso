
class QuranSurah {
  String name;
  int versesCount;

  QuranSurah({required this.name, required this.versesCount});
}

class QuranUtils {
  // Populated in the main method.
  static List<String> ayahs = [];

  // This map will be computed and saved for future use. This maps the
  // number of the first Ayah of every surah to its index in ayahs list.
  static Map<String, int> surahNameToFirstAyahIndex = {};

  static List<QuranSurah> getSortedQuranSuras() => surahNameToVersesCount
      .map((e) => QuranSurah(name: e['name'], versesCount: e['versesCount']))
      .toList();

  // ayahNum is zero-based.
  static String getAyahInSurah(String surahName, int ayahNum) {
    if (surahNameToFirstAyahIndex.isEmpty) {
      computeSurahsFirstIndices();
    }
    return ayahs[surahNameToFirstAyahIndex[surahName]! + ayahNum];
  }

  static const List surahNameToVersesCount = [
    {'name': 'ٱلْفَاتِحَةِ', 'versesCount': 7},
    {'name': 'البَقَرَةِ', 'versesCount': 286},
    {'name': 'آلِ عِمۡرَانَ', 'versesCount': 200},
    {'name': 'النِّسَاءِ', 'versesCount': 176},
    {'name': 'المَائـِدَةِ', 'versesCount': 120},
    {'name': 'الأَنۡعَامِ', 'versesCount': 165},
    {'name': 'الأَعۡرَافِ', 'versesCount': 206},
    {'name': 'الأَنفَالِ', 'versesCount': 75},
    {'name': 'التَّوۡبَةِ', 'versesCount': 129},
    {'name': 'يُونُسَ', 'versesCount': 109},
    {'name': 'هُودٍ', 'versesCount': 123},
    {'name': 'يُوسُفَ', 'versesCount': 111},
    {'name': 'الرَّعۡدِ', 'versesCount': 43},
    {'name': 'إِبۡرَاهِيمَ', 'versesCount': 52},
    {'name': 'الحِجۡرِ', 'versesCount': 99},
    {'name': 'النَّحۡلِ', 'versesCount': 128},
    {'name': 'الإِسۡرَاءِ', 'versesCount': 111},
    {'name': 'الكَهۡفِ', 'versesCount': 110},
    {'name': 'مَرۡيَمَ', 'versesCount': 98},
    {'name': 'طه', 'versesCount': 135},
    {'name': 'الأَنبِيَاءِ', 'versesCount': 112},
    {'name': 'الحَجِّ', 'versesCount': 78},
    {'name': 'المُؤۡمِنُونَ', 'versesCount': 118},
    {'name': 'النُّورِ', 'versesCount': 64},
    {'name': 'الفُرۡقَانِ', 'versesCount': 77},
    {'name': 'الشُّعَرَاءِ', 'versesCount': 227},
    {'name': 'النَّمۡلِ', 'versesCount': 93},
    {'name': 'القَصَصِ', 'versesCount': 88},
    {'name': 'العَنكَبُوتِ', 'versesCount': 69},
    {'name': 'الرُّومِ', 'versesCount': 60},
    {'name': 'لُقۡمَانَ', 'versesCount': 34},
    {'name': 'السَّجۡدَةِ', 'versesCount': 30},
    {'name': 'الأَحۡزَابِ', 'versesCount': 73},
    {'name': 'سَبَإٍ', 'versesCount': 54},
    {'name': 'فَاطِرٍ', 'versesCount': 45},
    {'name': 'يسٓ', 'versesCount': 83},
    {'name': 'الصَّافَّاتِ', 'versesCount': 182},
    {'name': 'صٓ', 'versesCount': 88},
    {'name': 'الزُّمَرِ', 'versesCount': 75},
    {'name': 'غَافِرٍ', 'versesCount': 85},
    {'name': 'فُصِّلَتۡ', 'versesCount': 54},
    {'name': 'الشُّورَىٰ', 'versesCount': 53},
    {'name': 'الزُّخۡرُفِ', 'versesCount': 89},
    {'name': 'الدُّخَانِ', 'versesCount': 59},
    {'name': 'الجَاثِيَةِ', 'versesCount': 37},
    {'name': 'الأَحۡقَافِ', 'versesCount': 35},
    {'name': 'مُحَمَّدٍ', 'versesCount': 38},
    {'name': 'الفَتۡحِ', 'versesCount': 29},
    {'name': 'الحُجُرَاتِ', 'versesCount': 18},
    {'name': 'قٓ', 'versesCount': 45},
    {'name': 'الذَّارِيَاتِ', 'versesCount': 60},
    {'name': 'الطُّورِ', 'versesCount': 49},
    {'name': 'النَّجۡمِ', 'versesCount': 62},
    {'name': 'القَمَرِ', 'versesCount': 55},
    {'name': 'الرَّحۡمَٰن', 'versesCount': 78},
    {'name': 'الوَاقِعَةِ', 'versesCount': 96},
    {'name': 'الحَدِيدِ', 'versesCount': 29},
    {'name': 'المُجَادلَةِ', 'versesCount': 22},
    {'name': 'الحَشۡرِ', 'versesCount': 24},
    {'name': 'المُمۡتَحنَةِ', 'versesCount': 13},
    {'name': 'الصَّفِّ', 'versesCount': 14},
    {'name': 'الجُمُعَةِ', 'versesCount': 11},
    {'name': 'المُنَافِقُونَ', 'versesCount': 11},
    {'name': 'التَّغَابُنِ', 'versesCount': 18},
    {'name': 'الطَّلَاقِ', 'versesCount': 12},
    {'name': 'التَّحۡرِيمِ', 'versesCount': 12},
    {'name': 'المُلۡكِ', 'versesCount': 30},
    {'name': 'القَلَمِ', 'versesCount': 52},
    {'name': 'الحَاقَّةِ', 'versesCount': 52},
    {'name': 'المَعَارِجِ', 'versesCount': 44},
    {'name': 'نُوحٍ', 'versesCount': 28},
    {'name': 'الجِنِّ', 'versesCount': 28},
    {'name': 'المُزَّمِّلِ', 'versesCount': 20},
    {'name': 'المُدَّثِّرِ', 'versesCount': 56},
    {'name': 'القِيَامَةِ', 'versesCount': 40},
    {'name': 'الإِنسَانِ', 'versesCount': 31},
    {'name': 'المُرۡسَلَاتِ', 'versesCount': 50},
    {'name': 'النَّبَإِ', 'versesCount': 40},
    {'name': 'النَّازِعَاتِ', 'versesCount': 46},
    {'name': 'عَبَسَ', 'versesCount': 42},
    {'name': 'التَّكۡوِيرِ', 'versesCount': 29},
    {'name': 'الانفِطَارِ', 'versesCount': 19},
    {'name': 'المُطَفِّفِينَ', 'versesCount': 36},
    {'name': 'الانشِقَاقِ', 'versesCount': 25},
    {'name': 'البُرُوجِ', 'versesCount': 22},
    {'name': 'الطَّارِقِ', 'versesCount': 17},
    {'name': 'الأَعۡلَىٰ', 'versesCount': 19},
    {'name': 'الغَاشِيَةِ', 'versesCount': 26},
    {'name': 'الفَجۡرِ', 'versesCount': 30},
    {'name': 'البَلَدِ', 'versesCount': 20},
    {'name': 'الشَّمۡسِ', 'versesCount': 15},
    {'name': 'اللَّيۡلِ', 'versesCount': 21},
    {'name': 'الضُّحَىٰ', 'versesCount': 11},
    {'name': 'الشَّرۡحِ', 'versesCount': 8},
    {'name': 'التِّينِ', 'versesCount': 8},
    {'name': 'العَلَقِ', 'versesCount': 19},
    {'name': 'القَدۡرِ', 'versesCount': 5},
    {'name': 'البَيِّنَةِ', 'versesCount': 8},
    {'name': 'الزَّلۡزَلَةِ', 'versesCount': 8},
    {'name': 'العَادِيَاتِ', 'versesCount': 11},
    {'name': 'القَارِعَةِ', 'versesCount': 11},
    {'name': 'التَّكَاثُرِ', 'versesCount': 8},
    {'name': 'العَصۡرِ', 'versesCount': 3},
    {'name': 'الهُمَزَةِ', 'versesCount': 9},
    {'name': 'الفِيلِ', 'versesCount': 5},
    {'name': 'قُرَيۡشٍ', 'versesCount': 4},
    {'name': 'المَاعُونِ', 'versesCount': 7},
    {'name': 'الكَوۡثَرِ', 'versesCount': 3},
    {'name': 'الكَافِرُونَ', 'versesCount': 6},
    {'name': 'النَّصۡرِ', 'versesCount': 3},
    {'name': 'المَسَدِ', 'versesCount': 5},
    {'name': 'الإِخۡلَاصِ', 'versesCount': 4},
    {'name': 'الفَلَقِ', 'versesCount': 5},
    {'name': 'النَّاسِ', 'versesCount': 6}
  ];

  static void computeSurahsFirstIndices() {
    int ayasCount = 0;
    for (var surahMap in surahNameToVersesCount) {
      surahNameToFirstAyahIndex[surahMap['name']] = ayasCount;
      ayasCount += (surahMap['versesCount']! as int);
    }
  }
}
