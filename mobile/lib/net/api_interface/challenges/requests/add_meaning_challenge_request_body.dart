import 'package:azkar/net/api_interface/request_base.dart';

class AddMeaningChallengeRequestBody extends RequestBodyBase {
  List<String> friendsIds;
  int expiryDate;
  int numberOfWords;

  AddMeaningChallengeRequestBody({
    required this.friendsIds,
    required this.expiryDate,
    required this.numberOfWords,
  });

  @override
  Map<String, dynamic> toJson() => {
        'friendsIds': friendsIds,
        'expiryDate': expiryDate,
        'numberOfWords': numberOfWords,
      };
}
