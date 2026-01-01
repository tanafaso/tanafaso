import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

typedef OnAddedToPubliclyAvailableUsersCallback = void Function();

class FindFriendsNotPubliclyAvailableWidget extends StatefulWidget {
  final OnAddedToPubliclyAvailableUsersCallback
      onAddedToPubliclyAvailableUsersCallback;

  FindFriendsNotPubliclyAvailableWidget(
      {required this.onAddedToPubliclyAvailableUsersCallback});

  @override
  _FindFriendsNotPubliclyAvailableWidgetState createState() =>
      _FindFriendsNotPubliclyAvailableWidgetState();
}

enum GenderState {
  NOT_CHOSEN,
  MALE,
  FEMALE,
}

class _FindFriendsNotPubliclyAvailableWidgetState
    extends State<FindFriendsNotPubliclyAvailableWidget> {
  late GenderState _genderState;
  late Color _maleButtonColor;
  late Color _femaleButtonColor;
  late bool _consentGiven;
  late ButtonState _searchButtonState;

  @override
  void initState() {
    super.initState();

    _genderState = GenderState.NOT_CHOSEN;
    _maleButtonColor = Colors.white;
    _femaleButtonColor = Colors.white;
    _consentGiven = false;
    _searchButtonState = ButtonState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        'أنا',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left: 8)),
                          Expanded(
                            child: RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  _genderState = GenderState.MALE;
                                  setButtonColors();
                                });
                              },
                              fillColor: _maleButtonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                'ذكر',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 8)),
                          Expanded(
                            child: RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  _genderState = GenderState.FEMALE;
                                  setButtonColors();
                                });
                              },
                              fillColor: _femaleButtonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              child:
                                  Text('أنثى', style: TextStyle(fontSize: 25)),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 8)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        'قبل البحث عن أصدقاء ، يجب أن توافق على أن المستخدمين الآخرين سيتمكنون من رؤية اسمك وسيتمكنون من إرسال طلبات صداقة إليك.',
                        style: TextStyle(fontSize: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                      ),
                      Text.rich(TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        children: [
                          TextSpan(
                              text: "ملاحظة: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  "ستتمكن في أي وقت من حذف نفسك من هذه القائمة."),
                        ],
                      )),
                      Padding(padding: EdgeInsets.only(top: 8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            side: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            overlayColor: WidgetStateProperty.resolveWith(
                                (_) => Colors.green.shade300),
                            checkColor: Colors.black,
                            fillColor: WidgetStateProperty.resolveWith(
                                (_) => Colors.white),
                            value: _consentGiven,
                            onChanged: (_) {
                              setState(() {
                                _consentGiven = !_consentGiven;
                              });
                            },
                          ),
                          Text(
                            "أنا موافق",
                            style: TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 8)),
            Row(
              children: [
                Expanded(
                  child: ProgressButton.icon(
                    textStyle: TextStyle(
                      color: Colors.black,
                    ),
                    iconedButtons: {
                      ButtonState.idle: IconedButton(
                          text: "ابحث",
                          icon: Icon(Icons.search, color: Colors.black),
                          color: Colors.white),
                      ButtonState.success: IconedButton(
                          icon: Icon(Icons.search, color: Colors.black),
                          color: Colors.green.shade700),
                      ButtonState.loading: IconedButton(
                          icon:
                              Icon(Icons.search, color: Colors.yellow.shade200),
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .primary),
                      ButtonState.fail: IconedButton(
                          icon: Icon(Icons.cancel, color: Colors.white),
                          color: Colors.red.shade300),
                    },
                    onPressed: () => onSearchPressed(),
                    state: _searchButtonState,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onSearchPressed() async {
    if (_searchButtonState == ButtonState.loading ||
        _searchButtonState == ButtonState.success) {
      return;
    }

    if (_searchButtonState == ButtonState.fail) {
      setState(() {
        _searchButtonState = ButtonState.idle;
      });
      return;
    }

    setState(() {
      _searchButtonState = ButtonState.loading;
    });

    if (_genderState == GenderState.NOT_CHOSEN) {
      SnackBarUtils.showSnackBar(
        context,
        'الرجاء تحديد ما إذا كنت ذكرا أو أنثى',
      );
      setState(() {
        _searchButtonState = ButtonState.fail;
      });
      return;
    }

    if (!_consentGiven) {
      SnackBarUtils.showSnackBar(
        context,
        'يجب أن توافق على البيان أعلاه أولاً',
      );
      setState(() {
        _searchButtonState = ButtonState.fail;
      });
      return;
    }

    try {
      if (_genderState == GenderState.MALE) {
        await ServiceProvider.usersService.addToPubliclyAvailableMales();
      } else {
        await ServiceProvider.usersService.addToPubliclyAvailableFemales();
      }
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(
        context,
        '${AppLocalizations.of(context).error}: ${e.errorStatus.errorMessage}',
      );
      setState(() {
        _searchButtonState = ButtonState.fail;
      });
      return;
    }

    setState(() {
      _searchButtonState = ButtonState.success;
      widget.onAddedToPubliclyAvailableUsersCallback();
    });
  }

  void setButtonColors() {
    switch (_genderState) {
      case GenderState.NOT_CHOSEN:
        _maleButtonColor = Colors.white;
        _femaleButtonColor = Colors.white;
        break;
      case GenderState.MALE:
        _maleButtonColor = Colors.green.shade300;
        _femaleButtonColor = Colors.white;
        break;
      case GenderState.FEMALE:
        _maleButtonColor = Colors.white;
        _femaleButtonColor = Colors.green.shade300;
        break;
    }
  }
}
