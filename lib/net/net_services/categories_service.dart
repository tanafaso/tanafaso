import 'dart:convert';

import 'package:azkar/net/api_caller.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/azkar/requests/get_categories_response.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:http/http.dart' as http;

class CategoriesService {
  Future<GetCategoriesResponse> getCategories() async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(endpointRoute: EndpointRoute.GET_CATEGORIES));

    var response = GetCategoriesResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response;
  }
}
