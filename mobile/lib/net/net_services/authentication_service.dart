import 'dart:convert';
import 'dart:io';

import 'package:azkar/net/api_caller.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/authentication/requests/apple_authentication_request_body.dart';
import 'package:azkar/net/api_interface/authentication/requests/email_login_request_body.dart';
import 'package:azkar/net/api_interface/authentication/requests/email_registration_request_body.dart';
import 'package:azkar/net/api_interface/authentication/requests/google_authentication_request_body.dart';
import 'package:azkar/net/api_interface/authentication/requests/reset_password_request_body.dart';
import 'package:azkar/net/api_interface/authentication/responses/apple_authentication_response.dart';
import 'package:azkar/net/api_interface/authentication/responses/email_login_response.dart';
import 'package:azkar/net/api_interface/authentication/responses/email_registration_response.dart';
import 'package:azkar/net/api_interface/authentication/responses/google_authentication_response.dart';
import 'package:azkar/net/api_interface/authentication/responses/reset_password_response.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:http/http.dart' as http;
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthenticationService {
  static const int FACEBOOK_INVALID_OAUTH_TOKEN_ERROR_CODE = 190;
  static const int MAXIMUM_FRIENDS_USING_APP_COUNT = 100;

  Future<void> loginWithGoogle(String googleIdToken) async {
    final http.Response apiResponse = await http.put(
        ApiCaller.buildUri(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.LOGIN_WITH_GOOGLE))),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(new GoogleAuthenticationRequestBody(
          googleIdToken: googleIdToken,
        ).toJson()));

    GoogleAuthenticationResponse response =
        GoogleAuthenticationResponse.fromJson(
            jsonDecode(utf8.decode(apiResponse.bodyBytes)));

    if (!response.hasError()) {
      final jwtToken = apiResponse.headers[HttpHeaders.authorizationHeader];
      await ServiceProvider.secureStorageService.setJwtToken(jwtToken!);
    }
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> loginWithApple() async {
    final AuthorizationResult result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        break;
      case AuthorizationStatus.error:
        print("Sign in failed: ${result.error?.localizedDescription}");
        throw new Exception(
            "Sign in failed: ${result.error?.localizedDescription}");
      case AuthorizationStatus.cancelled:
        print('User cancelled');
        throw new Exception("User cancelled");
    }

    String? email = result.credential?.email;
    String givenName = result.credential?.fullName?.givenName ?? "";
    String familyName = result.credential?.fullName?.familyName ?? "";

    if (email == null || email == "<null>" || email == givenName) {
      email = (await ServiceProvider.secureStorageService.getAppleIdEmail());
      givenName =
          (await ServiceProvider.secureStorageService.getAppleIdGivenName()) ??
              "";
      familyName =
          (await ServiceProvider.secureStorageService.getAppleIdFamilyName()) ??
              "";
    } else {
      // Cache user info as these are only returned the first time the
      // user attempts to sign in with Apple:
      // https://developer.apple.com/forums/thread/121496
      await ServiceProvider.secureStorageService.setAppleIdEmail(email);
      await ServiceProvider.secureStorageService.setAppleIdGivenName(givenName);
      await ServiceProvider.secureStorageService
          .setAppleIdFamilyName(familyName);
    }

    if (email == null || email.isEmpty) {
      throw new Exception("Email was not provided by Apple");
    }
    if (result.credential == null ||
        result.credential?.authorizationCode == null) {
      throw new Exception("Authorization code was not provided by Apple");
    }
    final http.Response apiResponse = await http.put(
        ApiCaller.buildUri(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.LOGIN_WITH_APPLE))),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(AppleAuthenticationRequestBody(
                email: email,
                firstName: givenName,
                lastName: familyName,
                authCode: utf8.decode(result.credential!.authorizationCode!))
            .toJson()));

    AppleAuthenticationResponse response = AppleAuthenticationResponse.fromJson(
        jsonDecode(utf8.decode(apiResponse.bodyBytes)));

    if (!response.hasError()) {
      final jwtToken = apiResponse.headers[HttpHeaders.authorizationHeader];
      await ServiceProvider.secureStorageService.setJwtToken(jwtToken!);
    }
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> signUp(EmailRegistrationRequestBody request) async {
    http.Response apiResponse;
    try {
      apiResponse = await http.put(
        ApiCaller.buildUri(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.REGISTER_WITH_EMAIL_V2))),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );
    } catch (e) {
      throw ApiException.withDefaultError();
    }

    var response = EmailRegistrationResponse.fromJson(
        jsonDecode(utf8.decode(apiResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> login(EmailLoginRequestBody request) async {
    http.Response apiResponse;
    try {
      apiResponse = await http.put(
        ApiCaller.buildUri(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.LOGIN_WITH_EMAIL))),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );
    } catch (e) {
      print('Error: An exception while requesting:'
          '${ApiRoutesUtil.apiRouteToString(Endpoint(endpointRoute: EndpointRoute.LOGIN_WITH_EMAIL))} '
          'with stack trace: ${e.toString()}');
      throw ApiException.withDefaultError();
    }

    var response = EmailLoginResponse.fromJson(
        jsonDecode(utf8.decode(apiResponse.bodyBytes)));

    if (!response.hasError()) {
      final jwtToken = apiResponse.headers[HttpHeaders.authorizationHeader];
      await ServiceProvider.secureStorageService.setJwtToken(jwtToken!);
    } else {
      throw new ApiException(response.error!);
    }
  }

  Future<void> resetPassword(String email) async {
    ResetPasswordRequestBody requestBody =
        ResetPasswordRequestBody(email: email);
    http.Response httpResponse = await ApiCaller.post(
        route: Endpoint(endpointRoute: EndpointRoute.RESET_PASSWORD),
        requestBody: requestBody);

    var response = ResetPasswordResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }
}
