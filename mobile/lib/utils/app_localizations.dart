import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'title': 'تنافسوا',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot password': 'هل نسيت كلمة مرور؟',
      'or login with': 'أو تسجيل الدخول باستخدام',
      'login': 'تسجيل الدخول',
      'sign up': 'اشتراك',
      'facebook': 'الفيسبوك',
      'password hint text': '********',
      'Password should be of at least 8 characters':
          'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',
      'name': 'الاسم',
      'confirm password': 'تأكيد كلمة المرور',
      'already have an account': 'هل لديك حساب؟',
      'passwords did not match': 'كلمات المرور غير متطابقة',
      'email is invalid': 'البريد الإلكتروني غير صحيح',
      'name example': 'مثال على الاسم',
      'name should be of at least 2 letters':
          'يجب أن يتكون الاسم من حرفين على الأقل',
      'ok': 'حسنا',
      'error': 'خطأ',
      'email verification': 'تأكيد بواسطة البريد الالكتروني',
      'enter the code sent to': 'أدخل الرمز المرسل إلى',
      'verification Successful': 'تم التحقق بنجاح',
      'email verified successfully': 'تم التحقق من البريد الإلكتروني بنجاح',
      'clear': 'مسح',
      'verify': 'تحقق',
      'resend': 'إعادة إرسال',
      'did not receive the code?': 'لم يصلك الرمز؟',
      'please fill up all the cells properly':
          'يرجى ملء جميع الخلايا بشكل صحيح',
      'the challenges': 'التحديات',
      'friends': 'الأصدقاء',
      'profile': 'الملف الشخصي',
      'home page': 'الصفحة الرئيسية',
      'username': 'كود المستخدم',
      'loading': 'جار التحميل',
      'friend requests': 'طلبات صداقة',
      'add friend': 'أضف صديق',
      'loading friends': 'تحميل الأصدقاء',
      'is now your friend': 'الان صديقك',
      'friend request': 'طلب صداقة',
      'is ignored': 'تم تجاهله',
      'ignore': 'تجاهل',
      'accept': 'قبول',
      'no friends found': 'لم يتم العثور على أصدقاء.',
      'how to add friends explanation': '''
هناك عدة طرق يمكنك بها إضافة أصدقاء.

عن طريق الفيسبوك إذا كان لدى أصدقائك التطبيق وربطوه بفيسبوك.
 ١- اضغط على أضف صديق.
 ٢- أضف صديق عن طريق فيسبوك.
 ٣- سيظهر لك أصدقاؤك في فيسبوك المتصلين بتطبيق تنافسوا.
 ٤- أرسل طلبات صداقة.
 ٥- سوف يتم إرسال طلب صداقة لهم وسيجدونها في قائمة طلبات الصداقة.

عن طريق كود المستخدم.
١- اضغط على الملف الشخصي أسفل الشاشة السابقة.
٢- تحت الاسم سيظهر لك الكود الخاص بك.
٣- اضغط على زر المشاركة الذي بجانبه.
٤- قم بمشاركة كود المستخدم الخاص بك مع أصدقائك.

إذا كان لديك الكود الخاص بصديقك و تريد اضافته.
١- اضغط على الأصدقاء الشاشة السابقة.
٢- اضف صديق.
٣- قم بكتابة أو لصق كود صديقك في خانة كود المستخدم.
٤- اضغط اضف.
٥- سوف يتم إرسال طلب صداقة لهم وسيجدونها في قائمة طلبات الصداقة و يستطيعون قبوله.
      ''',
      'invited': 'مدعو',
      'invite': 'أضف',
      'invite facebook Friends': 'دعوة أصدقاء الفيسبوك',
      'an invitation has been sent to': 'تم إرسال دعوة إلى',
      'connected facebook Successfully': 'تم ربط الفيسبوك بنجاح',
      'sent': 'تم ارساله',
      'failed': 'فشلت المحاولة',
      'sending': 'يتم إرسالها',
      'add facebook friend': 'إضافة صديق الفيسبوك',
      'connect your account with facebook': 'ربط حسابك بالفيسبوك',
      'or add friends by': 'أو أضف أصدقاء عن طريق',
      'username should have no spaces': 'يجب ألا يحتوي كود المستخدم على مسافات',
      'enter a username': 'أدخل كود المستخدم',
      'invite friends': 'ادعو أصدقاء',
      'no friend requests found': 'لم يتم العثور على طلبات صداقة',
      'create a challenge': 'أضف تحدي',
      'all challenges': 'كل التحديات',
      'personal challenges': 'التحديات الشخصية',
      'no personal challenges found': 'لم يتم العثور على تحديات شخصية',
      'loading the challenges': 'تحميل التحديات',
      'loading the challenge': 'تحميل التحدي',
      'ends after': 'ينتهي بعد',
      'hours': 'ساعات',
      'hour': 'ساعة',
      'minutes': 'دقائق',
      'minute': 'دقيقة',
      'ends after less than': 'ينتهي بعد أقل من',
      'passed': 'انتهى',
      'deadline': 'الموعد الأخير',
      'motivation': 'تحفيز',
      'no challenges found': 'لم يتم العثور على تحديات للأصدقاء',
      'name not found': 'لم يتم العثور على الاسم',
      'the friend': 'الصديق',
      'the group': 'المجموعة',
      'select zekr': 'اختر ذِكر',
      'add zekr': 'أضف ذِكر',
      'select friends': 'إختر أصدقاء',
      'you have not added any friends yet': 'لم تقم بإضافة أي أصدقاء بعد',
      'repetitions': 'التكرار',
      'no azkar selected': 'لم يتم اختيار أذكار',
      'the selected azkar': 'الأذكار المختارة',
      'change selected friends': 'تغيير الاصدقاء المختارين',
      'you will challenge': 'سوف تتحدى',
      'no friend selected': 'لم يتم اختيار أي صديق',
      'challenge has been added successfully': 'تمت إضافة التحدي بنجاح',
      'add': 'إضافة',
      'add (not ready)': 'إضافة (غير جاهز)',
      'days': 'أيام',
      'day': 'يوم',
      'challenge expires after': 'التحدي ينتهي بعد',
      'challenge name': 'اسم التحدي',
      'challenge friends': 'أتحدى أصدقائي',
      'challenge myself': 'أتحدى نفسي',
      'i want to': 'أريد أن',
      'days must be less than or equal 100':
          'يجب أن تكون الأيام أقل من أو تساوي 100',
      'days must be more than 0': 'يجب أن تكون الأيام أكثر من 0',
      'days must be a number from 1 to 100':
          'يجب أن تكون الأيام عبارة عن رقم من 1 إلى 100',
      'repetitions must be less than or equal 1000':
          'يجب أن تكون التكرارات أقل من 1000 أو تساويها',
      'repetitions must be more than 0': 'يجب أن يكون التكرار أكثر من 0',
      'repetitions must be a number from 1 to 1000':
          'يجب أن يكون عدد التكرار من 1 إلى 1000',
      'motivation should not be empty': 'لا ينبغي أن يكون الدافع فارغًا',
      'name should not be empty': 'يجب ألا يكون الاسم فارغًا',
      'click on zekr after reading it':
          'اضغط على الذكر بعد قراءته لحفظ تقدمك ولكي يتم إخطار أصدقائك بعد أن تنهي التحدي.',
      'you have finished reading it': 'لقد انتهيت من قراءته',
      'the remaining repetitions': 'التكرارات المتبقية',
      'you have finished the challenge successfully': 'لقد أنهيت التحدي بنجاح',
      'first name': 'الاسم الأول',
      'last name': 'اسم العائلة',
      'first name example': 'مثال على الاسم الأول',
      'last name example': 'مثال على اسم العائلة',
      'then': 'ثم',
      'you': 'أنت',
      'total points': 'مجموع النقاط',
      'challenge this friend': 'تحدي هذا الصديق',
      'your friend': 'صديقك',
      'you have finished': 'أنهيت',
      'challenges': 'تحديات',
      'username copied successfully': 'تم نسخ اسم المستخدم بنجاح',
      'search for a zekr': 'ابحث عن ذكر',
      'the deadline has already passed for this challenge':
          'لقد انقضى الموعد النهائي لهذا التحدي',
      'logout': 'تسجيل خروج',
      'you have logged out successfully': 'لقد قمت بتسجيل الخروج بنجاح',
      'an error happened while setting up this device to receive notifications':
          'حدث خطأ أثناء إعداد هذا الجهاز لتلقي الإخطارات',
      'you do not have an account?': 'ليس لديك حساب بعد؟',
      'no email provided': 'لم يتم تقديم بريد إلكتروني',
      'please connect to internet and try again':
          'حدث خطأ أثناء محاولة الاتصال بالإنترنت',
      'write something to motivate your friend to say the zekr':
          'اكتب شيئًا لتحفيز صديقك على قول الذكر',
      '(optional)': '(إختياري)',
      'the motivation message': 'رسالة التحفيز',
      'write a name with which you can distinguish the challenge':
          'اكتب اسمًا يمكنك من خلاله تمييز التحدي',
      'challenges of friends': 'تحديات الأصدقاء',
      'your friend can find his user code on his profile page':
          'يمكن لصديقك العثور على رمز المستخدم الخاص به في صفحة ملفه الشخصي.',
      'challenge target hint':
          'في تحدي الصديق، يمكنك انت وصديقك التنافس على القيام به وسيساهم إكماله في النتيجة بينك وبين صديقك وإجمالي نقاطك',
      'reset password': 'إعادة تعيين كلمة المرور',
      'enter your email address': 'أدخل عنوان بريدك الالكتروني',
      'send': 'إرسال',
      'an email will be sent to you so that you can reset your password':
          'سيتم إرسال بريد إلكتروني إليك حتى تتمكن من إعادة تعيين كلمة المرور الخاصة بك.',
      'an email has been sent to you, please check your inbox':
          'تم إرسال بريد إلكتروني إليك ، يرجى التحقق من صندوق الوارد الخاص بك',
      'please select azkar first': 'الرجاء اختيار الأذكار أولا',
      'select azkar': 'اختر الأذكار',
      'select azkar category': 'اختر فئة الأذكار',
      'add azkar': 'أضف أذكار',
      'please choose friends first': 'الرجاء اختيار الأصدقاء أولاً',
      'selected friends': 'الأصدقاء الذين تم اختيارهم',
      'and': 'و',
      'others': 'آخرون',
      'other': 'آخر',
      'repeating this challenge': 'تكرار هذا التحدي',
      'copy': 'نسخ',
      'the challenge has been deleted successfully': 'تم حذف التحدي بنجاح',
      'delete': 'حذف',
      'delete and copy challenge': 'حذف ونسخ التحدي',
      'swipe the challenge card to the right to delete or copy a challenge':
          'اسحب بطاقة التحدي إلى اليمين لحذف التحدي أو نسخه',
      'hours must be less than or equal 24':
          'يجب أن تكون الساعات أقل من أو تساوي ٢٤',
      'hours must be more than 0': 'يجب أن تكون الساعات أكثر من ٠',
      'hours must be a number from 1 to 24':
          'يجب أن تكون الساعات رقمًا من ١ إلى ٢٤',
      'share message':
          'تطبيق تنافسوا يساعد الأقارب والأصدقاء على أن يشجع بعضهم بعضا على ذكر الله.' +
              '\n\n' +
              'حمل التطبيق و أضفني يا صديقي لأشجعك وتشجعني.' +
              '\n\n' +
              'هذا هو كود المستخدم الخاص بي' +
              '\n'
                  '%s' +
              '\n\n' +
              'Android: https://play.google.com/store/apps/details?id=com.tanafaso.azkar \n' +
              '\n' +
              'iOS: https://apps.apple.com/us/app/تنافسوا/id1564309117\n',
      'share with friend': 'شارك مع صديق',
      'challenge creator': '(منشئ التحدي)',
      'doing a challenge': 'القيام بتحدي',
      'add the first friends challenge': 'أضف أول تحدي للأصدقاء',
      'how to add new friends': 'كيفية إضافة أصدقاء جدد',
      'share username explanation':
          'يمكنك مشاركة التطبيق وكود المستخدم الخاص بك مع أصدقائك على WhatsApp و Facebook وغيرها ...',
      'share username title': 'شارك مع الاصدقاء',
      'how to add new friends?': 'كيف يمكنني اضافة اصدقاء جدد؟',
      'filtered azkar not found': '''
لم نعثر على أذكار تحتوي على هذه الكلمات
حاول البحث بكلمات مختلفة''',
      'detailed view': 'عرض تفصيلي',
      'summary view': 'عرض ملخص',
      'challenge': 'تحدى',
      'sabeq and detailed view title': 'أهلاً بكم في صفحة الأصدقاء',
      'sabeq and detailed view explanation':
          'سابق هو أول أصدقائك على التطبيق. اضغط على سابق لتتمكن من تحديه ولرؤية المزيد من المعلومات حول صداقتكم.',
      'personal challenge not found temp error message':
          'يمكن فقط نسخ التحديات الشخصية التي تم إنشاؤها بدءًا من يونيو ٢٠٢١',
      'yes': 'نعم',
      'no': 'لا',
      'are you a new user?': 'هل أنت مستخدم جديد؟',
      'error while signing in with google':
          'حدث خطأ أثناء تسجيل الدخول باستخدام جوجل',
      'username should not be empty': 'يجب ألا يكون كود المستخدم فارغًا',
      'signing in...': 'جاري تسجيل الدخول...',
      'global challenge feature': 'تحدي مشترك',
      'global challenge feature description':
          'هذا تحدي مشترك بين جميع مستخدمي التطبيق',
      'global challenge': 'تحدي مشترك',
    },
  };

  String get signingIn {
    return _localizedValues[locale.languageCode]!['signing in...']!;
  }
  String get yes {
    return _localizedValues[locale.languageCode]!['yes']!;
  }

  String get no {
    return _localizedValues[locale.languageCode]!['no']!;
  }

  String get areYouANewUser {
    return _localizedValues[locale.languageCode]!['are you a new user?']!;
  }

  String get personalChallengeNotFoundTempErrorMessage {
    return _localizedValues[locale.languageCode]![
        'personal challenge not found temp error message']!;
  }

  String get sabeqAndDetailedViewTitle {
    return _localizedValues[locale.languageCode]![
        'sabeq and detailed view title']!;
  }

  String get sabeqAndDetailedViewExplanation {
    return _localizedValues[locale.languageCode]![
        'sabeq and detailed view explanation']!;
  }

  String get challenge {
    return _localizedValues[locale.languageCode]!['challenge']!;
  }

  String get detailedView {
    return _localizedValues[locale.languageCode]!['detailed view']!;
  }

  String get summaryView {
    return _localizedValues[locale.languageCode]!['summary view']!;
  }

  String get filteredAzkarNotFound {
    return _localizedValues[locale.languageCode]!['filtered azkar not found']!;
  }

  String get shareUsernameExplanation {
    return _localizedValues[locale.languageCode]![
        'share username explanation']!;
  }

  String get shareUsernameTitle {
    return _localizedValues[locale.languageCode]!['share username title']!;
  }

  String get noFriendsFound {
    return _localizedValues[locale.languageCode]!['no friends found']!;
  }

  String get howToAddNewFriendsQuestion {
    return _localizedValues[locale.languageCode]!['how to add new friends?']!;
  }

  String get howToAddNewFriends {
    return _localizedValues[locale.languageCode]!['how to add new friends']!;
  }

  String get addTheFirstFriendsChallenge {
    return _localizedValues[locale.languageCode]![
        'add the first friends challenge']!;
  }

  String get doingAChallenge {
    return _localizedValues[locale.languageCode]!['doing a challenge']!;
  }

  String get challengeCreator {
    return _localizedValues[locale.languageCode]!['challenge creator']!;
  }

  String get shareWithFriend {
    return _localizedValues[locale.languageCode]!['share with friend']!;
  }

  String shareMessage(String username) {
    return sprintf(
        _localizedValues[locale.languageCode]!['share message']!, [username]);
  }

  String get theChallengeHasBeenDeletedSuccessfully {
    return _localizedValues[locale.languageCode]![
        'the challenge has been deleted successfully']!;
  }

  String get deleteAndCopyChallenge {
    return _localizedValues[locale.languageCode]!['delete and copy challenge']!;
  }

  String get globalChallengeFeature {
    return _localizedValues[locale.languageCode]!['global challenge feature']!;
  }

  String get swipeTheChallengeCardToTheRightToDeleteOrCopyAChallenge {
    return _localizedValues[locale.languageCode]![
        'swipe the challenge card to the right to delete or copy a challenge']!;
  }

  String get globalChallengeFeatureDescription {
    return _localizedValues[locale.languageCode]!['global challenge feature description']!;
  }

  String get globalChallenge {
    return _localizedValues[locale.languageCode]!['global challenge']!;
  }

  String get copy {
    return _localizedValues[locale.languageCode]!['copy']!;
  }

  String get delete {
    return _localizedValues[locale.languageCode]!['delete']!;
  }

  String get repeatingThisChallenge {
    return _localizedValues[locale.languageCode]!['repeating this challenge']!;
  }

  String get other {
    return _localizedValues[locale.languageCode]!['other']!;
  }

  String get and {
    return _localizedValues[locale.languageCode]!['and']!;
  }

  String get selectedFriends {
    return _localizedValues[locale.languageCode]!['selected friends']!;
  }

  String get others {
    return _localizedValues[locale.languageCode]!['others']!;
  }

  String get pleaseChooseFriendsFirst {
    return _localizedValues[locale.languageCode]![
        'please choose friends first']!;
  }

  String get addAzkar {
    return _localizedValues[locale.languageCode]!['add azkar']!;
  }

  String get selectAzkarCategory {
    return _localizedValues[locale.languageCode]!['select azkar category']!;
  }

  String get selectAzkar {
    return _localizedValues[locale.languageCode]!['select azkar']!;
  }

  String get pleaseSelectAzkarFirst {
    return _localizedValues[locale.languageCode]!['please select azkar first']!;
  }

  String get anEmailHasBeenSentToYouPleaseCheckYourInbox {
    return _localizedValues[locale.languageCode]![
        'an email has been sent to you, please check your inbox']!;
  }

  String get anEmailWillBeSentToYouSoThatYouCanResetYourPassword {
    return _localizedValues[locale.languageCode]![
        'an email will be sent to you so that you can reset your password']!;
  }

  String get send {
    return _localizedValues[locale.languageCode]!['send']!;
  }

  String get enterYourEmailAddress {
    return _localizedValues[locale.languageCode]!['enter your email address']!;
  }

  String get resetPassword {
    return _localizedValues[locale.languageCode]!['reset password']!;
  }

  String get challengeTargetHint {
    return _localizedValues[locale.languageCode]!['challenge target hint']!;
  }

  String get yourFriendCanFindHisUserCodeOnHisProfilePage {
    return _localizedValues[locale.languageCode]![
        'your friend can find his user code on his profile page']!;
  }

  String get challengesOfFriends {
    return _localizedValues[locale.languageCode]!['challenges of friends']!;
  }

  String get optional {
    return _localizedValues[locale.languageCode]!['(optional)']!;
  }

  String get writeANameWithWhichYouCanDistinguishTheChallenge {
    return _localizedValues[locale.languageCode]![
        'write a name with which you can distinguish the challenge']!;
  }

  String get theMotivationMessage {
    return _localizedValues[locale.languageCode]!['the motivation message']!;
  }

  String get writeSomethingToMotivateYourFriendToSayTheZekr {
    return _localizedValues[locale.languageCode]![
        'write something to motivate your friend to say the zekr']!;
  }

  String get noEmailProvided {
    return _localizedValues[locale.languageCode]!['no email provided']!;
  }

  String get pleaseConnectToInternetAndTryAgain {
    return _localizedValues[locale.languageCode]![
        'please connect to internet and try again']!;
  }

  String get youDoNotHaveAnAccount {
    return _localizedValues[locale.languageCode]![
        'you do not have an account?']!;
  }

  String get anErrorHappenedWhileSettingUpThisDeviceToReceiveNotifications {
    return _localizedValues[locale.languageCode]![
        'an error happened while setting up this device to receive notifications']!;
  }

  String get youHaveLoggedOutSuccessfully {
    return _localizedValues[locale.languageCode]![
        'you have logged out successfully']!;
  }

  String get logout {
    return _localizedValues[locale.languageCode]!['logout']!;
  }

  String get theDeadlineHasAlreadyPassedForThisChallenge {
    return _localizedValues[locale.languageCode]![
        'the deadline has already passed for this challenge']!;
  }

  String get searchForAZekr {
    return _localizedValues[locale.languageCode]!['search for a zekr']!;
  }

  String get usernameCopiedSuccessfully {
    return _localizedValues[locale.languageCode]![
        'username copied successfully']!;
  }

  String get challenges {
    return _localizedValues[locale.languageCode]!['challenges']!;
  }

  String get youHaveFinished {
    return _localizedValues[locale.languageCode]!['you have finished']!;
  }

  String get yourFriend {
    return _localizedValues[locale.languageCode]!['your friend']!;
  }

  String get challengeThisFriend {
    return _localizedValues[locale.languageCode]!['challenge this friend']!;
  }

  String get you {
    return _localizedValues[locale.languageCode]!['you']!;
  }

  String get totalPoints {
    return _localizedValues[locale.languageCode]!['total points']!;
  }

  String get then {
    return _localizedValues[locale.languageCode]!['then']!;
  }

  String get firstNameExample {
    return _localizedValues[locale.languageCode]!['first name example']!;
  }

  String get lastNameExample {
    return _localizedValues[locale.languageCode]!['last name example']!;
  }

  String get firstName {
    return _localizedValues[locale.languageCode]!['first name']!;
  }

  String get lastName {
    return _localizedValues[locale.languageCode]!['last name']!;
  }

  String get day {
    return _localizedValues[locale.languageCode]!['day']!;
  }

  String get hour {
    return _localizedValues[locale.languageCode]!['hour']!;
  }

  String get minute {
    return _localizedValues[locale.languageCode]!['minute']!;
  }

  String get youHaveFinishedTheChallengeSuccessfully {
    return _localizedValues[locale.languageCode]![
        'you have finished the challenge successfully']!;
  }

  String get theRemainingRepetitions {
    return _localizedValues[locale.languageCode]!['the remaining repetitions']!;
  }

  String get youHaveFinishedReadingIt {
    return _localizedValues[locale.languageCode]![
        'you have finished reading it']!;
  }

  String get clickOnZekrAfterReadingIt {
    return _localizedValues[locale.languageCode]![
        'click on zekr after reading it']!;
  }

  String get repetitions {
    return _localizedValues[locale.languageCode]!['repetitions']!;
  }

  String get challengeMyself {
    return _localizedValues[locale.languageCode]!['challenge myself']!;
  }

  String get addZekr {
    return _localizedValues[locale.languageCode]!['add zekr']!;
  }

  String get noAzkarSelected {
    return _localizedValues[locale.languageCode]!['no azkar selected']!;
  }

  String get theSelectedAzkar {
    return _localizedValues[locale.languageCode]!['the selected azkar']!;
  }

  String get changeSelectedFriends {
    return _localizedValues[locale.languageCode]!['change selected friends']!;
  }

  String get youWillChallenge {
    return _localizedValues[locale.languageCode]!['you will challenge']!;
  }

  String get noFriendsSelected {
    return _localizedValues[locale.languageCode]!['no friend selected']!;
  }

  String get challengeHasBeenAddedSuccessfully {
    return _localizedValues[locale.languageCode]![
        'challenge has been added successfully']!;
  }

  String get add {
    return _localizedValues[locale.languageCode]!['add']!;
  }

  String get addNotReady {
    return _localizedValues[locale.languageCode]!['add (not ready)']!;
  }

  String get days {
    return _localizedValues[locale.languageCode]!['days']!;
  }

  String get challengeExpiresAfter {
    return _localizedValues[locale.languageCode]!['challenge expires after']!;
  }

  String get challengeName {
    return _localizedValues[locale.languageCode]!['challenge name']!;
  }

  String get challengeFriends {
    return _localizedValues[locale.languageCode]!['challenge friends']!;
  }

  String get iWantTo {
    return _localizedValues[locale.languageCode]!['i want to']!;
  }

  String get selectFriends {
    return _localizedValues[locale.languageCode]!['select friends']!;
  }

  String get daysMustBeLessThanOrEqual100 {
    return _localizedValues[locale.languageCode]![
        'days must be less than or equal 100']!;
  }

  String get daysMustBeMoreThan0 {
    return _localizedValues[locale.languageCode]!['days must be more than 0']!;
  }

  String get daysMustBeANumberFrom1to100 {
    return _localizedValues[locale.languageCode]![
        'days must be a number from 1 to 100']!;
  }

  String get hoursMustBeLessThanOrEqual24 {
    return _localizedValues[locale.languageCode]![
        'hours must be less than or equal 24']!;
  }

  String get hoursMustBeMoreThan0 {
    return _localizedValues[locale.languageCode]!['hours must be more than 0']!;
  }

  String get hoursMustBeANumberFrom1to24 {
    return _localizedValues[locale.languageCode]![
        'hours must be a number from 1 to 24']!;
  }

  String get repetitionsMustBeLessThanOrEqual1000 {
    return _localizedValues[locale.languageCode]![
        'repetitions must be less than or equal 1000']!;
  }

  String get repetitionsMustBeMoreThan0 {
    return _localizedValues[locale.languageCode]![
        'repetitions must be more than 0']!;
  }

  String get repetitionsMustBeANumberFrom1to1000 {
    return _localizedValues[locale.languageCode]![
        'repetitions must be a number from 1 to 1000']!;
  }

  String get youHaveNotAddedAnyFriendsYet {
    return _localizedValues[locale.languageCode]![
        'you have not added any friends yet']!;
  }

  String get motivationShouldNotBeEmpty {
    return _localizedValues[locale.languageCode]![
        'motivation should not be empty']!;
  }

  String get nameShouldNotBeEmpty {
    return _localizedValues[locale.languageCode]!['name should not be empty']!;
  }

  String get selectZekr {
    return _localizedValues[locale.languageCode]!['select zekr']!;
  }

  String get nameNotFound {
    return _localizedValues[locale.languageCode]!['name not found']!;
  }

  String get theFriend {
    return _localizedValues[locale.languageCode]!['the friend']!;
  }

  String get theGroup {
    return _localizedValues[locale.languageCode]!['the group']!;
  }

  String get motivation {
    return _localizedValues[locale.languageCode]!['motivation']!;
  }

  String get noChallengesFound {
    return _localizedValues[locale.languageCode]!['no challenges found']!;
  }

  String get endsAfter {
    return _localizedValues[locale.languageCode]!['ends after']!;
  }

  String get hours {
    return _localizedValues[locale.languageCode]!['hours']!;
  }

  String get minutes {
    return _localizedValues[locale.languageCode]!['minutes']!;
  }

  String get endsAfterLessThan {
    return _localizedValues[locale.languageCode]!['ends after less than']!;
  }

  String get passed {
    return _localizedValues[locale.languageCode]!['passed']!;
  }

  String get deadline {
    return _localizedValues[locale.languageCode]!['deadline']!;
  }

  String get noPersonalChallengesFound {
    return _localizedValues[locale.languageCode]![
        'no personal challenges found']!;
  }

  String get createAChallenge {
    return _localizedValues[locale.languageCode]!['create a challenge']!;
  }

  String get loadingTheChallenges {
    return _localizedValues[locale.languageCode]!['loading the challenges']!;
  }

  String get loadingTheChallenge {
    return _localizedValues[locale.languageCode]!['loading the challenge']!;
  }

  String get allChallenges {
    return _localizedValues[locale.languageCode]!['all challenges']!;
  }

  String get personalChallenges {
    return _localizedValues[locale.languageCode]!['personal challenges']!;
  }

  String get noFriendRequestsFound {
    return _localizedValues[locale.languageCode]!['no friend requests found']!;
  }

  String get inviteFriends {
    return _localizedValues[locale.languageCode]!['invite friends']!;
  }

  String get connectedFacebookSuccessfully {
    return _localizedValues[locale.languageCode]![
        'connected facebook Successfully']!;
  }

  String get sent {
    return _localizedValues[locale.languageCode]!['sent']!;
  }

  String get failed {
    return _localizedValues[locale.languageCode]!['failed']!;
  }

  String get sending {
    return _localizedValues[locale.languageCode]!['sending']!;
  }

  String get addFacebookFriend {
    return _localizedValues[locale.languageCode]!['add facebook friend']!;
  }

  String get connectYourAccountWithFacebook {
    return _localizedValues[locale.languageCode]![
        'connect your account with facebook']!;
  }

  String get inviteFacebookFriends {
    return _localizedValues[locale.languageCode]!['invite facebook Friends']!;
  }

  String get orAddFriendsBy {
    return _localizedValues[locale.languageCode]!['or add friends by']!;
  }

  String get usernameShouldHaveNoSpaces {
    return _localizedValues[locale.languageCode]![
        'username should have no spaces']!;
  }

  String get usernameShouldNotBeEmpty {
    return _localizedValues[locale.languageCode]![
        'username should not be empty']!;
  }

  String get errorWhileSigningInWithGoogle {
    return _localizedValues[locale.languageCode]![
        'error while signing in with google']!;
  }

  String get enterAUsername {
    return _localizedValues[locale.languageCode]!['enter a username']!;
  }

  String get invited {
    return _localizedValues[locale.languageCode]!['invited']!;
  }

  String get invite {
    return _localizedValues[locale.languageCode]!['invite']!;
  }

  String get anInvitationHasBeenSentTo {
    return _localizedValues[locale.languageCode]![
        'an invitation has been sent to']!;
  }

  String get howToAddFriendsExplanation {
    return _localizedValues[locale.languageCode]![
        'how to add friends explanation']!;
  }

  String get ignore {
    return _localizedValues[locale.languageCode]!['ignore']!;
  }

  String get accept {
    return _localizedValues[locale.languageCode]!['accept']!;
  }

  String get isNowYourFriend {
    return _localizedValues[locale.languageCode]!['is now your friend']!;
  }

  String get friendRequest {
    return _localizedValues[locale.languageCode]!['friend request']!;
  }

  String get isIgnored {
    return _localizedValues[locale.languageCode]!['is ignored']!;
  }

  String get loadingFriends {
    return _localizedValues[locale.languageCode]!['loading friends']!;
  }

  String get addFriend {
    return _localizedValues[locale.languageCode]!['add friend']!;
  }

  String get friendRequests {
    return _localizedValues[locale.languageCode]!['friend requests']!;
  }

  String get loading {
    return _localizedValues[locale.languageCode]!['loading']!;
  }

  String get username {
    return _localizedValues[locale.languageCode]!['username']!;
  }

  String get theChallenges {
    return _localizedValues[locale.languageCode]!['the challenges']!;
  }

  String get homePage {
    return _localizedValues[locale.languageCode]!['home page']!;
  }

  String get friends {
    return _localizedValues[locale.languageCode]!['friends']!;
  }

  String get profile {
    return _localizedValues[locale.languageCode]!['profile']!;
  }

  String get enterTheCodeSentTo {
    return _localizedValues[locale.languageCode]!['enter the code sent to']!;
  }

  String get clear {
    return _localizedValues[locale.languageCode]!['clear']!;
  }

  String get resend {
    return _localizedValues[locale.languageCode]!['resend']!;
  }

  String get didNotReceiveTheCjode {
    return _localizedValues[locale.languageCode]!['did not receive the code']!;
  }

  String get pleaseFillUpAllTheCellsProperly {
    return _localizedValues[locale.languageCode]![
        'please fill up all the cells properly']!;
  }

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }

  String get email {
    return _localizedValues[locale.languageCode]!['email']!;
  }

  String get password {
    return _localizedValues[locale.languageCode]!['password']!;
  }

  String get forgotPassword {
    return _localizedValues[locale.languageCode]!['forgot password']!;
  }

  String get orLoginWith {
    return _localizedValues[locale.languageCode]!['or login with']!;
  }

  String get login {
    return _localizedValues[locale.languageCode]!['login']!;
  }

  String get signUp {
    return _localizedValues[locale.languageCode]!['sign up']!;
  }

  String get facebook {
    return _localizedValues[locale.languageCode]!['facebook']!;
  }

  String get passwordHintText {
    return _localizedValues[locale.languageCode]!['password hint text']!;
  }

  String get passwordShouldBeOfAtLeast8Characters {
    return _localizedValues[locale.languageCode]![
        'Password should be of at least 8 characters']!;
  }

  String get name {
    return _localizedValues[locale.languageCode]!['name']!;
  }

  String get confirmPassword {
    return _localizedValues[locale.languageCode]!['confirm password']!;
  }

  String get alreadyHaveAnAccount {
    return _localizedValues[locale.languageCode]!['already have an account']!;
  }

  String get passwordsDidNotMatch {
    return _localizedValues[locale.languageCode]!['passwords did not match']!;
  }

  String get emailIsInvalid {
    return _localizedValues[locale.languageCode]!['email is invalid']!;
  }

  String get nameExample {
    return _localizedValues[locale.languageCode]!['name example']!;
  }

  String get nameShouldBeOfAtLeast2Letters {
    return _localizedValues[locale.languageCode]![
        'name should be of at least 2 letters']!;
  }

  String get ok {
    return _localizedValues[locale.languageCode]!['ok']!;
  }

  String get error {
    return _localizedValues[locale.languageCode]!['error']!;
  }

  String get emailVerification {
    return _localizedValues[locale.languageCode]!['email verification']!;
  }

  String get verify {
    return _localizedValues[locale.languageCode]!['verify']!;
  }

  String get verificationSuccessful {
    return _localizedValues[locale.languageCode]!['verification Successful']!;
  }

  String get emailVerifiedSuccessfully {
    return _localizedValues[locale.languageCode]![
        'email verified successfully']!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => ['ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
