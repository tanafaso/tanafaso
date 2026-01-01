import 'package:azkar/views/auth/auth_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthMainScreen()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    var pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: Colors.green.shade900),
      bodyTextStyle: bodyStyle,
      pageColor: Theme.of(context).colorScheme.primary,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Theme.of(context).colorScheme.primary,
      globalFooter: Align(
        alignment: Alignment.center,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
          ),
        ),
      ),
      globalHeader: Align(
        alignment: Alignment.center,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
          ),
        ),
      ),
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showNextButton: true,
      next: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
      ),
      done: Padding(
        padding: const EdgeInsets.all(0),
        child: Icon(
          Icons.done,
          size: 30,
          color: Colors.black,
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.only(bottom: 3 * 8.0, left: 8, right: 8),
      rtl: true,
      controlsPadding: const EdgeInsets.all(16.0),
      dotsFlex: 2,
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.black,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(),
      ),
      pages: [
        PageViewModel(
          title: "مرحبا بكم في تنافسوا 🔥",
          body: "شجع أقاربك و أصدقائك وتنافس معهم على ذكر الله",
          image: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        child: Icon(
                          Icons.directions_run,
                          color: Colors.green.shade800,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "كود المستخدم",
          body:
              "بعد تسجيل الدخول، سيتم تعيين رمز لك. يمكن لأصدقائك استخدام هذا الرمز لإرسال طلب صداقة إليك. تستطيع العثور على هذا الرمز ونسخه ومشاركته مع أصدقائك من خلال صفحة الملف الشخصي. ",
          image: _buildImage('username.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "إضافة الأصدقاء",
          body:
              "إذا شارك صديق لك رمز المستخدم معك، فيمكنك إرسال طلب صداقة إليه عن طريق لصق رمز المستخدم الخاص به في صفحة دعوة الأصدقاء",
          image: _buildImage('add_friend.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "تحدي الأصدقاء",
          body: "يمكنك اختيار الأصدقاء وتحدِّيهم لقراءة بعض الأذكار وتكرارها",
          image: _buildImage('challenge.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "متابعة التقدم",
          body: "يمكنك متابعة تقدمك وتقدم أصدقائك في صفحة الأصدقاء",
          image: _buildImage('friends.png'),
          decoration: pageDecoration,
        ),
      ],
    );
  }
}
