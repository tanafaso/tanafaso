import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/models/zekr.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class WriteZekrScreen extends StatefulWidget {
  @override
  State<WriteZekrScreen> createState() => _WriteZekrScreenState();
}

class _WriteZekrScreenState extends State<WriteZekrScreen> {
  late TextEditingController _zekrTextController;
  late ButtonState _progressButtonState;
  late String _lastZekrText = "";

  @override
  void initState() {
    super.initState();

    _zekrTextController = new TextEditingController(text: _lastZekrText);
    _zekrTextController.addListener(() {
      if (_lastZekrText == _zekrTextController.value.text) {
        return;
      }
      _lastZekrText = _zekrTextController.value.text;
      setState(() {});
    });
    _progressButtonState = ButtonState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'اكتب الذكر',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Flexible(
                child: TextField(
                  maxLength: 300,
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  showCursor: true,
                  cursorColor: Colors.black,
                  autofocus: true,
                  decoration: new InputDecoration(
                    enabledBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                      borderSide: new BorderSide(color: Colors.black),
                    ),
                    focusedBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                      borderSide: new BorderSide(color: Colors.black),
                    ),
                    border: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                  ),
                  controller: _zekrTextController,
                ),
              ),
              Padding(padding: EdgeInsets.all(4)),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: !readyToFinishChallenge(false)
                          ? getNotReadyButton()
                          : getReadyButton(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getNotReadyButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ButtonTheme(
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey),
          ),
          onPressed: () async => onAddPressed(),
          child: Center(
              child: Text(
            AppLocalizations.of(context).addNotReady,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

  Widget getReadyButton() {
    return ProgressButton.icon(
      textStyle: TextStyle(
        color: Colors.black,
      ),
      iconedButtons: {
        ButtonState.idle: IconedButton(
            // text: AppLocalizations.of(context).add,
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 30,
            ),
            color: Colors.green.shade300),
        ButtonState.loading: IconedButton(
            text: AppLocalizations.of(context).sending,
            color: Colors.yellow.shade200),
        ButtonState.fail: IconedButton(
            text: AppLocalizations.of(context).failed,
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: AppLocalizations.of(context).login,
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      },
      onPressed: onProgressButtonClicked,
      state: _progressButtonState,
    );
  }

  void onProgressButtonClicked() {
    switch (_progressButtonState) {
      case ButtonState.idle:
        setState(() {
          _progressButtonState = ButtonState.loading;
        });

        onAddPressed();
        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        break;
      case ButtonState.fail:
        _progressButtonState = ButtonState.idle;
        break;
    }
    setState(() {
      _progressButtonState = _progressButtonState;
    });
  }

  onAddPressed() async {
    if (!readyToFinishChallenge(true)) {
      return;
    }
    List<SubChallenge> selectedZekr = [
      SubChallenge(
          zekr: Zekr(
              id: Zekr.customZekrIdOffset,
              zekr: _zekrTextController.value.text),
          repetitions: 1)
    ];
    Navigator.pop(context, selectedZekr);
  }

  bool readyToFinishChallenge(bool showWarnings) {
    if (_zekrTextController.value.text.length < 4) {
      if (showWarnings) {
        SnackBarUtils.showSnackBar(
            context, "يجب أن تكون عدد الحروف على الأقل 4.");
      }
      return false;
    }

    if (_zekrTextController.value.text.length > 300) {
      if (showWarnings) {
        SnackBarUtils.showSnackBar(context, "يجب ألا تزيد عدد الحروف عن 300.");
      }
      return false;
    }
    return true;
  }
}
