import 'dart:math';

import 'package:azkar/models/category.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/models/zekr.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/azkar/requests/get_categories_response.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_azkar/select_category_screen.dart';
import 'package:flutter/material.dart';

typedef OnSelectedAzkarChangedCallback = void Function(
    List<SubChallenge> newSubChallenge);
typedef OnSelectedAzkarValidityChangedCallback = void Function(bool valid);

class SelectedAzkarWidget extends StatefulWidget {
  final OnSelectedAzkarChangedCallback onSelectedAzkarChangedCallback;
  final OnSelectedAzkarValidityChangedCallback
      onSelectedAzkarValidityChangedCallback;
  final List<SubChallenge> initiallySelectedSubChallenges;

  SelectedAzkarWidget({
    required this.onSelectedAzkarChangedCallback,
    required this.onSelectedAzkarValidityChangedCallback,
    this.initiallySelectedSubChallenges = const [],
  });

  @override
  _SelectedAzkarWidgetState createState() => _SelectedAzkarWidgetState();
}

class _SelectedAzkarWidgetState extends State<SelectedAzkarWidget>
    with AutomaticKeepAliveClientMixin {
  late List<SubChallenge> _subChallenges;
  List<TextEditingController> _repetitionsControllers = [];

  @override
  void initState() {
    super.initState();
    _subChallenges = widget.initiallySelectedSubChallenges;
    for (var subChallenge in _subChallenges) {
      var controller =
          TextEditingController(text: subChallenge.repetitions.toString());
      _repetitionsControllers.add(controller);
      controller.addListener(() {
        if (validateRepetition(controller.value.text, true)) {
          subChallenge.repetitions =
              ArabicUtils.stringToNumber(controller.value.text);
        }
        notifyParentWithDataChanges();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Necessary as documented by AutomaticKeepAliveClientMixin.
    super.build(context);

    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.list,
                  size: 25,
                ),
              ),
              getAzkarSelectedTitleConditionally(),
            ],
          ),
          Visibility(
              visible: _subChallenges.length > 0, child: getSubChallenges()),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              style: ButtonStyle(
                  elevation: WidgetStateProperty.resolveWith((states) => 10),
                  shape: WidgetStateProperty.resolveWith((_) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
              onPressed: () {
                onAddAzkarPressed();
              },
              child: _subChallenges.length == 0
                  ? Icon(Icons.add, color: Theme.of(context).iconTheme.color)
                  : Text(
                      AppLocalizations.of(context).addAzkar,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  getSubChallenges() {
    return Container(
      height: 310,
      child: Scrollbar(
        child: ListView.builder(
          itemCount: _subChallenges.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return zekrItem(context, index);
          },
        ),
      ),
    );
  }

  zekrItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 2 * MediaQuery.of(context).size.width / 3,
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            _subChallenges[index].zekr.zekr!,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: Theme.of(context)
                                    .primaryTextTheme
                                    .labelLarge!
                                    .fontFamily),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(left: 1),
                    )),
                    Text(
                      AppLocalizations.of(context).repetitions,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 70,
                        height: 30,
                        alignment: Alignment.center,
                        child: Card(
                          elevation: 1,
                          child: TextField(
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.ltr,
                            decoration: new InputDecoration(
                              alignLabelWithHint: true,
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                            ),
                            // textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            controller: _repetitionsControllers[index],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(left: 1),
                    )),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _subChallenges.removeAt(index);
                          _repetitionsControllers.removeAt(index);
                          widget.onSelectedAzkarChangedCallback
                              .call(_subChallenges);
                        });
                      },
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAzkarSelectedTitleConditionally() {
    final String text = _subChallenges.length == 0
        ? AppLocalizations.of(context).noAzkarSelected
        : AppLocalizations.of(context).theSelectedAzkar;
    Color color = _subChallenges.length == 0 ? Colors.pink : Colors.black;
    return FittedBox(
      child: Text(
        text,
        style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: color),
      ),
    );
  }

  onAddAzkarPressed() async {
    List<Category> categories;
    try {
      GetCategoriesResponse response =
          await ServiceProvider.azkarService.getCategories();
      categories = response.categories;
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(
        context,
        e.errorStatus.errorMessage,
      );
      return;
    }
    List<SubChallenge> selectedAzkar = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectCategoryScreen(
                  categories: categories,
                ))) as List<SubChallenge>;

    if (selectedAzkar.length == 0) {
      return;
    }

    setState(() {
      _subChallenges = mergeChallenges(_subChallenges, selectedAzkar);
      _repetitionsControllers = [];
      _subChallenges.forEach((subChallenge) {
        TextEditingController controller = TextEditingController(
            text: ArabicUtils.englishToArabic(
                subChallenge.repetitions.toString()));
        controller.addListener(() {
          if (validateRepetition(controller.value.text, true)) {
            subChallenge.repetitions =
                ArabicUtils.stringToNumber(controller.value.text);
          }
          notifyParentWithDataChanges();
        });
        _repetitionsControllers.add(controller);
      });
      notifyParentWithDataChanges();
    });
  }

  void notifyParentWithDataChanges() {
    sendRepetitionsValiditySignal();
    widget.onSelectedAzkarChangedCallback(_subChallenges);
  }

  void sendRepetitionsValiditySignal() {
    bool allValid = true;
    for (TextEditingController repetitionsController
        in _repetitionsControllers) {
      if (!validateRepetition(repetitionsController.value.text, false)) {
        allValid = false;
        break;
      }
    }
    widget.onSelectedAzkarValidityChangedCallback(allValid);
  }

  bool validateRepetition(String repetition, bool showWarning) {
    int repetitionsNum = 0;
    try {
      repetitionsNum = ArabicUtils.stringToNumber(repetition);
    } on FormatException {
      if (showWarning) {
        SnackBarUtils.showSnackBar(
          context,
          AppLocalizations.of(context).repetitionsMustBeANumberFrom1to1000,
        );
      }
      return false;
    }
    if (repetitionsNum <= 0) {
      if (showWarning) {
        SnackBarUtils.showSnackBar(
          context,
          AppLocalizations.of(context).repetitionsMustBeMoreThan0,
        );
      }
      return false;
    }

    if (repetitionsNum > 1000) {
      if (showWarning) {
        SnackBarUtils.showSnackBar(
          context,
          AppLocalizations.of(context).repetitionsMustBeLessThanOrEqual1000,
        );
      }
      return false;
    }
    return true;
  }

  List<SubChallenge> mergeChallenges(
      List<SubChallenge> subChallenges, List<SubChallenge> newSubChallenges) {
    Map<int, SubChallenge> merged = new Map();

    // Used to keep track of the last custom challenge ID.
    int maxId = 0;
    for (SubChallenge subChallenge in subChallenges) {
      merged[subChallenge.zekr.id!] = subChallenge;
      maxId = max(maxId, subChallenge.zekr.id!);
    }
    for (SubChallenge subChallenge in newSubChallenges) {
      if (subChallenge.zekr.id == Zekr.customZekrIdOffset) {
        subChallenge.zekr.id = maxId + 1;
      }
      merged[subChallenge.zekr.id!] = subChallenge;
    }

    return merged.values.toList();
  }

  @override
  bool get wantKeepAlive => true;
}
