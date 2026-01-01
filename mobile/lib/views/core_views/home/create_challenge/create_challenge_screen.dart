import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_azkar_challenge_screen.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_custom_simple_challenge_screen.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_meaning_challenge_screen.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_memorization_challenge_screen.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_reading_quran_challenge_screen.dart';
import 'package:flutter/material.dart';

class CreateChallengeScreen extends StatelessWidget {
  final List<Friend> initiallySelectedFriends;

  CreateChallengeScreen({this.initiallySelectedFriends = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "اختر نوع التحدي",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scrollbar(
          thumbVisibility: true,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: FittedBox(
                      child: Text(
                        '﴿وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَُ﴾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: Theme.of(context)
                                .primaryTextTheme.labelLarge!
                                .fontFamily),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "قراءة أذكار",
                              maxLines: 1,
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: false,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    collapsedBackgroundColor:
                        Theme.of(context).colorScheme.secondary,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    collapsedTextColor: Colors.black,
                    collapsedIconColor: Colors.black,
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                    ),
                    onExpansionChanged: (bool expanded) {},
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'اختر مجموعة من الأذكار وتكرار كل ذِكر وتحدى نفسك و بعض أصدقائك أن يقرؤوها.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 25),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      RawMaterialButton(
                        fillColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CreateAzkarChallengeScreen(
                                    initiallySelectedFriends:
                                        initiallySelectedFriends,
                                  )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.create),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'إنشاء التحدي',
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "معاني كلمات القرآن",
                              maxLines: 1,
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: false,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    collapsedBackgroundColor:
                        Theme.of(context).colorScheme.secondary,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    collapsedTextColor: Colors.black,
                    collapsedIconColor: Colors.black,
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                    ),
                    onExpansionChanged: (bool expanded) {},
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'تحدى نفسك و بعض أصدقائك أن يختاروا المعاني الصحيحة لعدد معين من كلمات القرآن الكريم.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 25),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      RawMaterialButton(
                        fillColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CreateMeaningChallengeScreen(
                                    initiallySelectedFriends:
                                        initiallySelectedFriends,
                                  )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.create),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'إنشاء التحدي',
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "قراءة قرآن",
                              maxLines: 1,
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: false,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    collapsedBackgroundColor:
                        Theme.of(context).colorScheme.secondary,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    collapsedTextColor: Colors.black,
                    collapsedIconColor: Colors.black,
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                    ),
                    onExpansionChanged: (bool expanded) {},
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'تحدى نفسك وبعض أصدقائك أن يقرؤوا بعض آيات القرآن الكريم.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 25),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      RawMaterialButton(
                        fillColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CreateReadingQuranChallengeScreen(
                                    initiallySelectedFriends:
                                        initiallySelectedFriends,
                                  )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.create),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'إنشاء التحدي',
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "اختبار حفظ قرآن",
                              maxLines: 1,
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: false,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    collapsedBackgroundColor:
                        Theme.of(context).colorScheme.secondary,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    collapsedTextColor: Colors.black,
                    collapsedIconColor: Colors.black,
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                    ),
                    onExpansionChanged: (bool expanded) {},
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'تحدى نفسك وبعض أصدقائك في قوة حفظ بعض أجزاء القرآن.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 25),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      RawMaterialButton(
                        fillColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CreateMemorizationChallengeScreen(
                                    initiallySelectedFriends:
                                        initiallySelectedFriends,
                                  )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.create),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'إنشاء التحدي',
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  customChallengeWidget(
                      context, "صيام", 'تحدى نفسك وبعض أصدقائك في الصيام.', [
                    "يوم الإثنين",
                    "يوم الخميس",
                    "يوم عاشوراء",
                    "يوم عرفة",
                    "يوم من شوال"
                  ]),
                  Padding(padding: EdgeInsets.all(4)),
                  customChallengeWidget(context, "صلاة",
                      'تحدى نفسك وبعض أصدقائك في صلوات النوافل.', [
                    "سنة الفجر",
                    "سنة الظهر",
                    "سنة العصر",
                    "سنة المغرب",
                    "سنة العشاء",
                    "الوتر",
                    "الضحى",
                    "الخسوف والكسوف",
                    "القيام",
                  ]),
                  Padding(padding: EdgeInsets.all(4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customChallengeWidget(BuildContext context, String title,
      String explanation, List<String> descriptions) {
    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ),
      initiallyExpanded: false,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      collapsedBackgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.black,
      iconColor: Colors.black,
      collapsedTextColor: Colors.black,
      collapsedIconColor: Colors.black,
      trailing: Icon(
        Icons.arrow_drop_down,
        size: 30,
      ),
      onExpansionChanged: (bool expanded) {},
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            explanation,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 25),
          ),
        ),
        Padding(padding: EdgeInsets.all(4)),
        ListView.builder(
          itemCount: descriptions.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: RawMaterialButton(
                fillColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateCustomSimpleChallengeScreen(
                            initiallySelectedFriends: initiallySelectedFriends,
                            description: title + " " + descriptions[index],
                          )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.create),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        descriptions[index],
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
        Padding(padding: EdgeInsets.all(4)),
      ],
    );
  }
}
