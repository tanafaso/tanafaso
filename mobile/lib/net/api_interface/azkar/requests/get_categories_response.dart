import 'package:azkar/models/category.dart';

import '../../response_base.dart';

class GetCategoriesResponse extends ResponseBase {
  late List<Category> categories;

  static GetCategoriesResponse fromJson(Map<String, dynamic> json) {
    GetCategoriesResponse response = new GetCategoriesResponse();
    response.setError(json);

    if (response.hasError()) {
      return response;
    }

    response.categories = [];
    for (var listItem in json['data']) {
      response.categories.add(Category.fromJson(listItem));
    }
    return response;
  }
}
