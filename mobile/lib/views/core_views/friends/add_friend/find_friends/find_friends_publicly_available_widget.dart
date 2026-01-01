import 'package:azkar/models/publicly_available_user.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/friends/add_friend/find_friends/publicly_available_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

typedef OnRemovedFromPubliclyAvailableListCallback = void Function();
typedef OnNeedNextPageCallback = void Function();

class FindFriendsPubliclyAvailableWidget extends StatefulWidget {
  final List<PubliclyAvailableUser> publiclyAvailableUsers;
  final OnNeedNextPageCallback onNeedNextPageCallback;

  FindFriendsPubliclyAvailableWidget({
    required this.publiclyAvailableUsers,
    required this.onNeedNextPageCallback,
  });

  @override
  _FindFriendsPubliclyAvailableWidgetState createState() =>
      _FindFriendsPubliclyAvailableWidgetState();
}

class _FindFriendsPubliclyAvailableWidgetState
    extends State<FindFriendsPubliclyAvailableWidget> {
  late ButtonState _removeFromPubliclyAvailableListButtonState;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _removeFromPubliclyAvailableListButtonState = ButtonState.idle;
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop) {
          this.widget.onNeedNextPageCallback();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget noUsersWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "لا يوجد أشخاص متاحون في هذه القائمة. نظرًا لأننا بدأنا دعم هذا مؤخرًا ، يرجى العودة لاحقًا ونأمل أن تجد المزيد من الأشخاص 😀",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 25),
      ),
    );

    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'إذا كنت لا تريد أن يراك الآخرون في هذه القائمة بعد الآن ، فاضغط على الزر التالي',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  ProgressButton.icon(
                    textStyle: TextStyle(
                      color: Colors.black,
                    ),
                    iconedButtons: {
                      ButtonState.idle: IconedButton(
                          icon: Icon(Icons.delete, color: Colors.black),
                          color: Colors.white),
                      ButtonState.loading: IconedButton(
                          text: AppLocalizations.of(context).sending,
                          icon: Icon(Icons.circle, color: Colors.white),
                          color: Colors.yellow.shade200),
                      ButtonState.fail: IconedButton(
                          icon: Icon(Icons.cancel, color: Colors.white),
                          color: Colors.red.shade300),
                      ButtonState.success: IconedButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          color: Colors.green.shade400)
                    },
                    onPressed: onRemoveFromPubliclyAvailableListPressed,
                    state: _removeFromPubliclyAvailableListButtonState,
                  )
                ],
              ),
            ),
          ),
          widget.publiclyAvailableUsers.length == 0
              ? noUsersWidget
              : Expanded(
                  child: Scrollbar(
                    controller: _controller,
                    thumbVisibility: true,
                    child: ListView.builder(
                      itemCount: widget.publiclyAvailableUsers.length,
                      controller: _controller,
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return PubliclyAvailableUserWidget(
                          publiclyAvailableUser:
                              widget.publiclyAvailableUsers[index],
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void onRemoveFromPubliclyAvailableListPressed() async {
    if (_removeFromPubliclyAvailableListButtonState == ButtonState.loading ||
        _removeFromPubliclyAvailableListButtonState == ButtonState.success) {
      return;
    }

    if (_removeFromPubliclyAvailableListButtonState == ButtonState.fail) {
      setState(() {
        _removeFromPubliclyAvailableListButtonState = ButtonState.idle;
      });
      return;
    }

    setState(() {
      _removeFromPubliclyAvailableListButtonState = ButtonState.loading;
    });

    try {
      await ServiceProvider.usersService.deleteFromPubliclyAvailableUsers();
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(
        context,
        '${AppLocalizations.of(context).error}: ${e.errorStatus.errorMessage}',
      );
      setState(() {
        _removeFromPubliclyAvailableListButtonState = ButtonState.fail;
      });
      return;
    }

    setState(() {
      _removeFromPubliclyAvailableListButtonState = ButtonState.success;
      Navigator.pop(context);
    });
  }
}
