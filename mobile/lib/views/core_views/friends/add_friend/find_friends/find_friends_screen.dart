import 'package:azkar/models/publicly_available_user.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/status.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/snapshot_utils.dart';
import 'package:azkar/views/core_views/friends/add_friend/find_friends/find_friends_not_publicly_available_widget.dart';
import 'package:azkar/views/core_views/friends/add_friend/find_friends/find_friends_publicly_available_widget.dart';
import 'package:azkar/views/core_views/friends/add_friend/find_friends/publicly_available_user_loading_widget.dart';
import 'package:flutter/material.dart';

class FindFriendsScreen extends StatefulWidget {
  @override
  _FindFriendsScreenState createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  late Future<void> _neededData;
  late List<PubliclyAvailableUser> _publiclyAvailableUsers;
  late bool _isPubliclyAvailableUser;
  String? _errorMessage;
  late int _pageNum;
  late bool _pageEmpty;
  late bool _nextPageNeeded;

  Future<void> getNeededData() async {
    try {
      _publiclyAvailableUsers = await ServiceProvider.usersService
          .getPubliclyAvailableUsersWithPage(0);
      _isPubliclyAvailableUser = true;
    } on ApiException catch (e) {
      if (e.errorStatus.code ==
          Status.USER_NOT_ADDED_TO_PUBLICLY_AVAILABLE_USERS_ERROR) {
        _isPubliclyAvailableUser = false;
      } else {
        _errorMessage = e.errorStatus.errorMessage;
      }
    }
    return Future.value();
  }

  @override
  void initState() {
    super.initState();

    _publiclyAvailableUsers = [];
    _isPubliclyAvailableUser = true;
    _neededData = getNeededData();
    _pageNum = 0;
    _pageEmpty = false;
    _nextPageNeeded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FittedBox(
        child: Text(
          "ابحث عن صديق",
          style: TextStyle(fontSize: 30),
        ),
      )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
            future: _neededData,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                if (_errorMessage != null) {
                  return Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SnapshotUtils.getErrorWidget(context, snapshot),
                      )
                    ],
                  );
                }

                if (!_isPubliclyAvailableUser) {
                  return FindFriendsNotPubliclyAvailableWidget(
                    onAddedToPubliclyAvailableUsersCallback: () {
                      setState(() {
                        _neededData = getNeededData();
                      });
                    },
                  );
                }
                return Column(
                  children: [
                    Flexible(
                      flex: 6,
                      child: FindFriendsPubliclyAvailableWidget(
                        publiclyAvailableUsers: _publiclyAvailableUsers,
                        onNeedNextPageCallback: () {
                          setState(() {
                            _nextPageNeeded = true;
                          });
                        },
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Visibility(
                          visible: _nextPageNeeded && !_pageEmpty,
                          maintainSize: false,
                          child: RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  _nextPageNeeded = false;
                                });
                                getNextPage();
                              },
                              fillColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_downward),
                                  Text("ابحث عن المزيد من الأصدقاء")
                                ],
                              )),
                        ),
                      ),
                    )
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: List.generate(
                      5, (_) => PubliclyAvailableUserLoadingWidget()),
                );
              } else {
                return Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                          'حدثت مشكلة أثناء جلب قائمة المستخدمين الذين يمكن اكتشافهم'),
                    )
                  ],
                );
              }
            }),
      ),
    );
  }

  void getNextPage() async {
    List<PubliclyAvailableUser> newPageList = await ServiceProvider.usersService
        .getPubliclyAvailableUsersWithPage(_pageNum + 1);
    setState(() {
      _pageNum = _pageNum + 1;
      _pageEmpty = newPageList.isEmpty;
      _publiclyAvailableUsers.addAll(newPageList);
    });
  }
}
