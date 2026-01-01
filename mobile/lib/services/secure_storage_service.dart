import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String JWT_TOKEN_STORAGE_KEY = 'jwtToken';
  static const String FACEBOOK_TOKEN_STORAGE_KEY = 'facebookAccessToken';
  static const String FACEBOOK_USER_ID_STORAGE_KEY = 'facebookUserId';
  static const String APPLE_ID_EMAIL = 'appleIdEmail';
  static const String APPLE_ID_GIVEN_NAME = 'appleIdGivenName';
  static const String APPLE_ID_FAMILY_NAME = 'appleIdFamilyName';

  Future<String?> getFacebookToken() async {
    return await _readKey(FACEBOOK_TOKEN_STORAGE_KEY);
  }

  Future<String?> getFacebookUserId() async {
    return await _readKey(FACEBOOK_USER_ID_STORAGE_KEY);
  }

  Future<String?> getJwtToken() async {
    return await _readKey(JWT_TOKEN_STORAGE_KEY);
  }

  Future<String?> _readKey(String key) async {
    final _storage = FlutterSecureStorage();
    bool keyInEncryptedStorage =
        await _storage.containsKey(key: key, aOptions: _getAndroidOptions());
    if (keyInEncryptedStorage) {
      return (await _storage.read(key: key, aOptions: _getAndroidOptions()))!;
    }

    bool keyInNonEncryptedStorage = await _storage.containsKey(key: key);
    if (keyInNonEncryptedStorage) {
      // Migrate to encrypted storage
      String? value = await _storage.read(key: key);
      await _storage.write(
          key: key, value: value, aOptions: _getAndroidOptions());
      return value;
    }

    return null;
  }

  Future<void> setFacebookToken(String facebookToken) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(
        key: FACEBOOK_TOKEN_STORAGE_KEY,
        value: facebookToken,
        aOptions: _getAndroidOptions());
  }

  Future<void> setFacebookUserId(String userId) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(
        key: FACEBOOK_USER_ID_STORAGE_KEY,
        value: userId,
        aOptions: _getAndroidOptions());
  }

  Future<void> setJwtToken(String jwtToken) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(
        key: JWT_TOKEN_STORAGE_KEY,
        value: jwtToken,
        aOptions: _getAndroidOptions());
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> setAppleIdEmail(String email) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(key: APPLE_ID_EMAIL, value: email);
  }

  Future<String?> getAppleIdEmail() async {
    final _storage = FlutterSecureStorage();
    return await _storage.read(key: APPLE_ID_EMAIL);
  }

  Future<void> setAppleIdGivenName(String firstName) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(key: APPLE_ID_GIVEN_NAME, value: firstName);
  }

  Future<String?> getAppleIdGivenName() async {
    final _storage = FlutterSecureStorage();
    return await _storage.read(key: APPLE_ID_GIVEN_NAME);
  }

  Future<void> setAppleIdFamilyName(String lastName) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(key: APPLE_ID_FAMILY_NAME, value: lastName);
  }

  Future<String?> getAppleIdFamilyName() async {
    final _storage = FlutterSecureStorage();
    return await _storage.read(key: APPLE_ID_FAMILY_NAME);
  }

  Future<void> clear() async {
    final _storage = FlutterSecureStorage();
    if (await _storage.containsKey(key: JWT_TOKEN_STORAGE_KEY))
      await _storage.delete(key: JWT_TOKEN_STORAGE_KEY);
    if (await _storage.containsKey(key: FACEBOOK_TOKEN_STORAGE_KEY))
      await _storage.delete(key: FACEBOOK_TOKEN_STORAGE_KEY);
    if (await _storage.containsKey(key: FACEBOOK_USER_ID_STORAGE_KEY))
      await _storage.delete(key: FACEBOOK_USER_ID_STORAGE_KEY);

    if (await _storage.containsKey(
        key: JWT_TOKEN_STORAGE_KEY, aOptions: _getAndroidOptions()))
      await _storage.delete(
          key: JWT_TOKEN_STORAGE_KEY, aOptions: _getAndroidOptions());
    if (await _storage.containsKey(
        key: FACEBOOK_TOKEN_STORAGE_KEY, aOptions: _getAndroidOptions()))
      await _storage.delete(
          key: FACEBOOK_TOKEN_STORAGE_KEY, aOptions: _getAndroidOptions());
    if (await _storage.containsKey(
        key: FACEBOOK_USER_ID_STORAGE_KEY, aOptions: _getAndroidOptions()))
      await _storage.delete(
          key: FACEBOOK_USER_ID_STORAGE_KEY, aOptions: _getAndroidOptions());
    // Don't delete apple's email, names as these will only provided the
    // first time the user is trying to sign in: https://developer.apple.com/forums/thread/121496
  }

  Future<bool> userSignedIn() async {
    final _storage = FlutterSecureStorage();
    String token;
    try {
      token = (await _storage.read(
          key: JWT_TOKEN_STORAGE_KEY, aOptions: _getAndroidOptions()))!;
    } catch (e) {
      return false;
    }
    return (token.length ?? 0) != 0;
  }
}
