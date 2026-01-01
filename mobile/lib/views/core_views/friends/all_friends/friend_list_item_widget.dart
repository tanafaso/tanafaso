import 'package:azkar/models/friend.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/features.dart';
import 'package:azkar/views/core_views/friends/all_friends/detailed_friend_list_item_widget.dart';
import 'package:azkar/views/core_views/friends/all_friends/summary_friend_list_item_widget.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

class FriendListItemWidget extends StatefulWidget {
  final Friend friendshipScores;
  final OnFriendDeletedCallback onFriendDeletedCallback;

  FriendListItemWidget({
    required this.friendshipScores,
    required this.onFriendDeletedCallback,
  });

  @override
  _FriendListItemWidgetState createState() => _FriendListItemWidgetState();
}

class _FriendListItemWidgetState extends State<FriendListItemWidget> {
  late bool _detailedView;
  late bool _isSabeq;

  @override
  void initState() {
    super.initState();

    _isSabeq = false;
    _detailedView = false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        String sabeqId = await ServiceProvider.usersService.getSabeqId();
        if (mounted) {
          setState(() {
            _isSabeq = sabeqId == widget.friendshipScores.userId;
          });
        }
      } catch (e) {
        // Silently fail if unable to get sabeq ID (e.g., timeout)
        if (mounted) {
          setState(() {
            _isSabeq = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isSabeq
        ? getMainWidget()
        : DescribedFeatureOverlay(
            key: Key(Features.SABEQ_INTRODUCTION),
            featureId: Features.SABEQ_INTRODUCTION,
            overflowMode: OverflowMode.wrapBackground,
            barrierDismissible: false,
            backgroundDismissible: false,
            contentLocation: ContentLocation.below,
            tapTarget: Icon(Icons.done_outline),
            // The widget that will be displayed as the tap target.
            description: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppLocalizations.of(context)
                                .sabeqAndDetailedViewTitle,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'سابق',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
                              new TextSpan(
                                  text:
                                      ' هو صديق افتراضي لك على التطبيق. اضغط على سابق لتتمكن من تحديه ولرؤية المزيد من المعلومات حول صداقتكم.'),
                            ],
                          ),
                          maxLines: 10,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            targetColor: Theme.of(context).colorScheme.secondary,
            textColor: Colors.black,
            child: getMainWidget());
  }

  Widget getMainWidget() {
    return _detailedView
        ? DetailedFriendListItemWidget(
            friendshipScore: widget.friendshipScores,
            toggleViewCallback: () {
              setState(() {
                _detailedView = false;
              });
            },
            onFriendDeletedCallback: () {
              widget.onFriendDeletedCallback.call();
            },
          )
        : SummaryFriendListItemWidget(
            friendshipScore: widget.friendshipScores,
            toggleViewCallback: () {
              setState(() {
                _detailedView = true;
              });
            },
          );
  }
}
