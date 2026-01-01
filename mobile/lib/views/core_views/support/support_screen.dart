import 'package:azkar/views/core_views/support/live_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'الاستفسارات',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                        child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'كيف أضيف أصدقاء؟',
                        style: TextStyle(fontSize: 30),
                      ),
                    ))
                  ],
                ),
                initiallyExpanded: false,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                collapsedBackgroundColor:
                    Theme.of(context).colorScheme.secondary,
                textColor: Colors.green.shade600,
                iconColor: Colors.green.shade600,
                collapsedTextColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '''يمكنك إضافة أصدقاء بأكثر من طريقة.
                    
١- عن طريق الفيسبوك. في صفحة الأصدقاء اضغط على زر علامة الزائد، ثم اضغط على أضف صديق. ثم زر فيسبوك.

٢- يمكنك مشاركة التطبيق وكود المستخدم الخاص بك مع أصدقائك من خلال الذهاب لصفحة الأصدقاء ثم ضغط زر الزائد ثم الضغط على زر المشاركة.

٣- إذا كنت تعرف كود المستخدم الخاص بصديق، يمكنك الذهاب لصفحة الأصدقاء ثم ضغط زر الزائد ثم ضغط زر الإضافة ثم إدخال كود المستخدم الخاص بصديقك وسيتم إرسال طلب صداقة له.
يمكنك إيجاد كود المستخدم الخاص بك في صفحة الملف الشخصي تحت الإسم. 

٤- يمكنك بحث عن أصدقاء من خلال البرنامج بضغط زر الزائد في صفحة الأصدقاء ثم ضغط اضافة أصدقاء ثم ضغط زر البحث. ''',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'ما هي فكرة البرنامج؟',
                              style: TextStyle(fontSize: 30),
                            ))),
                  ],
                ),
                initiallyExpanded: false,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                collapsedBackgroundColor:
                    Theme.of(context).colorScheme.secondary,
                textColor: Colors.green.shade600,
                iconColor: Colors.green.shade600,
                collapsedTextColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '''تطبيق تنافسوا يساعد الأقارب والأصدقاء على أن يشجع بعضهم بعضا على ذكر الله.

يتنافس الإنسان على مدار يومه مع نفسه وأقرانه لكي يرفع مستواه المادي أو الاجتماعي في الدنيا، ولكن نادراً ما يتنافس مع أحد حتى يرفع درجاته في جنات النعيم. فلم لا نتنافس مع من نحب في ذكر الله فترتفع درجاتنا وتطمئن قلوبنا. (الَّذِينَ آمَنُواْ وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ أَلاَ بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ)الرعد ٢٨

فكرة البرنامج أن يسهل عليك تشجيع أقاربك وأصدقائك على ذكر الله. يمكنك إضافة أصدقاء وإرسال تحديات لهم. ويمكنك تجربة ذلك بأن تتحدي الصديق الوهمي "سابق".

التحديات يمكن ان تكون في صورة قراءة اذكار او قراءة قرءان او اختبار لحفظ القران او اختبار في معاني كلمات القران. 
 ''',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                        child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'من هو سابق؟',
                        style: TextStyle(fontSize: 30),
                      ),
                    ))
                  ],
                ),
                initiallyExpanded: false,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                collapsedBackgroundColor:
                    Theme.of(context).colorScheme.secondary,
                textColor: Colors.green.shade600,
                iconColor: Colors.green.shade600,
                collapsedTextColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '''"سابق" هو صديق وهمي لك على تطبيق تنافسوا. يمكنك ان تتحدى نفسك من خلال أن ترسل تحديات لصديقك الوهمي سابق.''',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                        child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'أين التحديات؟',
                        style: TextStyle(fontSize: 30),
                      ),
                    ))
                  ],
                ),
                initiallyExpanded: false,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                collapsedBackgroundColor:
                    Theme.of(context).colorScheme.secondary,
                textColor: Colors.green.shade600,
                iconColor: Colors.green.shade600,
                collapsedTextColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '''فكرة البرنامج أن يسهل عليك تشجيع أقاربك وأصدقائك على ذكر الله. يمكنك إضافة أصدقاء وإرسال تحديات لهم. ويمكنك تجربة ذلك بأن تتحدي الصديق الوهمي "سابق".''',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'أنا مبرمج, كيف أساعد؟',
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
                textColor: Colors.green.shade600,
                iconColor: Colors.green.shade600,
                collapsedTextColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          '''يمكنك مشاركتنا في تطوير البرنامج''',
                          style: TextStyle(fontSize: 20),
                        ),
                        new InkWell(
                            child: new Text(
                              'https://github.com/tanafaso/tanafaso-frontend',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () =>
                                // ignore: deprecated_member_use
                                launch(
                                    'https://github.com/tanafaso/tanafaso-frontend')),
                        new InkWell(
                            child: new Text(
                              'https://github.com/tanafaso/tanafaso-backend',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () =>
                                // ignore: deprecated_member_use
                                launch(
                                    'https://github.com/tanafaso/tanafaso-backend')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RawMaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LiveSupportScreen())),
                fillColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ألديك استفسار آخر؟',
                    style:
                        TextStyle(fontSize: 25, color: Colors.green.shade600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
