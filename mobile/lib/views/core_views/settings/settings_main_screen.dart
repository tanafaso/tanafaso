import 'package:azkar/services/font_service.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsMainScreen extends StatefulWidget {
  @override
  _SettingsMainScreenState createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen> {
  late RepeatInterval currentlySelectedRepeatValue;
  late String _currentlySelectedAzkarAndQuranFontFamily;
  late String _currentlySelectedNonAzkarAndNonQuranFontFamily;

  @override
  void initState() {
    super.initState();

    currentlySelectedRepeatValue = RepeatInterval.weekly;
    _currentlySelectedAzkarAndQuranFontFamily =
        FontService.DEFAULT_AZKAR_AND_QURAN_FONT_FAMILY;
    _currentlySelectedNonAzkarAndNonQuranFontFamily =
        FontService.DEFAULT_NON_AZKAR_AND_NON_QURAN_FONT_FAMILY;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      RepeatInterval preferredRepeatInterval = await ServiceProvider
          .localNotificationsService
          .getCurrentNudgeInterval();
      String preferredAzkarAndQuranFontFamily = await ServiceProvider
          .fontService
          .getPreferredAzkarAndQuranFontFamily();
      String preferredNonAzkarAndNonQuranFontFamily = await ServiceProvider
          .fontService
          .getPreferredNonAzkarAndNonQuranFontFamily();

      if (mounted) {
        setState(() {
          currentlySelectedRepeatValue = preferredRepeatInterval;
          _currentlySelectedAzkarAndQuranFontFamily =
              preferredAzkarAndQuranFontFamily;
          _currentlySelectedNonAzkarAndNonQuranFontFamily =
              preferredNonAzkarAndNonQuranFontFamily;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "الإعدادات",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 45,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(8)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "التنبيهات لتحدي الأصدقاء",
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              minWidth: 0,
                              child: DropdownButton<RepeatInterval>(
                                value: currentlySelectedRepeatValue,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                focusColor: Colors.black,
                                elevation: 4,
                                style: const TextStyle(color: Colors.black),
                                underline: Container(
                                  height: 1,
                                  color: Colors.black,
                                ),
                                onChanged: (RepeatInterval? newValue) {
                                  ServiceProvider.localNotificationsService
                                      .setNudgeInterval(newValue!);
                                  setState(() {
                                    currentlySelectedRepeatValue = newValue;
                                  });
                                },
                                items: <RepeatInterval>[
                                  RepeatInterval.daily,
                                  RepeatInterval.weekly,
                                ].map<DropdownMenuItem<RepeatInterval>>(
                                    (RepeatInterval repeatInterval) {
                                  return DropdownMenuItem<RepeatInterval>(
                                    value: repeatInterval,
                                    child: Text(
                                        ServiceProvider
                                            .localNotificationsService
                                            .nudgeIntervalToString(
                                                repeatInterval),
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "خط الأذكار والقرآن",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 30,
                                              ),
                                            )))
                                  ])),
                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              minWidth: 0,
                              child: DropdownButton<String>(
                                value:
                                    _currentlySelectedAzkarAndQuranFontFamily,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                focusColor: Colors.black,
                                elevation: 4,
                                style: const TextStyle(color: Colors.black),
                                underline: Container(
                                  height: 1,
                                  color: Colors.black,
                                ),
                                onChanged: (String? newValue) {
                                  ServiceProvider.fontService
                                      .setPreferredAzkarAndQuranFontFamily(
                                          context, newValue!);
                                  setState(() {
                                    _currentlySelectedAzkarAndQuranFontFamily =
                                        newValue;
                                  });
                                },
                                items: ServiceProvider.fontService
                                    .getAllAzkarAndQuranFontFamilyOptions()
                                    .map<DropdownMenuItem<String>>(
                                        (String fontFamily) {
                                  return DropdownMenuItem<String>(
                                    value: fontFamily,
                                    child: Text(
                                        'بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily,
                                        )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "خط ما دون الأذكار والقرآن",
                                              style: TextStyle(
                                                fontSize: 30,
                                              ),
                                            )))
                                  ])),
                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              minWidth: 0,
                              child: DropdownButton<String>(
                                value:
                                    _currentlySelectedNonAzkarAndNonQuranFontFamily,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                focusColor: Colors.black,
                                elevation: 4,
                                style: const TextStyle(color: Colors.black),
                                underline: Container(
                                  height: 1,
                                  color: Colors.black,
                                ),
                                onChanged: (String? newValue) {
                                  ServiceProvider.fontService
                                      .setPreferredNonAzkarAndNonQuranFontFamily(
                                          context, newValue!);
                                  setState(() {
                                    _currentlySelectedNonAzkarAndNonQuranFontFamily =
                                        newValue;
                                  });
                                },
                                items: ServiceProvider.fontService
                                    .getAllNonAzkarAndNonQuranFontFamilyOptions()
                                    .map<DropdownMenuItem<String>>(
                                        (String fontFamily) {
                                  return DropdownMenuItem<String>(
                                    value: fontFamily,
                                    child: Text('مثال على الخط العام',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily,
                                        )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
