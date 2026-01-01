import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/net/net_services/authentication_service.dart';
import 'package:azkar/net/net_services/categories_service.dart';
import 'package:azkar/net/net_services/challenges_service.dart';
import 'package:azkar/net/net_services/groups_service.dart';
import 'package:azkar/net/net_services/home_service.dart';
import 'package:azkar/services/font_service.dart';
import 'package:azkar/services/secure_storage_service.dart';
import 'package:azkar/net/net_services/users_service.dart';
import 'package:azkar/services/local_notifications_service.dart';
import 'package:http/http.dart' as http;

/// Holds instances of the application services. This should be the main access
/// point to services used by widgets. That is to make mocking these services in
/// tests as easy as setting the service instance to the mock instance.
class ServiceProvider {
  static HomeService homeService = HomeService();
  static AuthenticationService authenticationService = AuthenticationService();
  static ChallengesService challengesService = ChallengesService();
  static UsersService usersService = UsersService();
  static GroupsService groupsService = GroupsService();
  static SecureStorageService secureStorageService = SecureStorageService();
  static CategoriesService azkarService = CategoriesService();
  static CacheManager cacheManager = CacheManager();
  static FontService fontService = FontService();
  static LocalNotificationsService localNotificationsService =
      LocalNotificationsService();
  static http.Client httpClient = http.Client();
}
