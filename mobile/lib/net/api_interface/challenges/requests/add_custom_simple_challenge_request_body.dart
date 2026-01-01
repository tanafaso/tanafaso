import 'package:azkar/net/api_interface/request_base.dart';

class AddCustomSimpleChallengeRequestBody extends RequestBodyBase {
  List<String> friendsIds;
  int expiryDate;
  String description;

  AddCustomSimpleChallengeRequestBody({
    required this.friendsIds,
    required this.expiryDate,
    required this.description,
  });

  @override
  Map<String, dynamic> toJson() => {
        'friendsIds': friendsIds,
        'description': description,
        'expiryDate': expiryDate,
      };
}
