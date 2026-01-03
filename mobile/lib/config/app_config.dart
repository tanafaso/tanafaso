import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kReleaseMode;

/// App configuration for managing environment-specific settings
class AppConfig {
  // Automatically uses production in release mode, local backend in debug mode
  static bool get useProdBackend => kReleaseMode;

  // Local backend addresses
  static const String localBackendAndroid = '10.0.2.2:8080';
  static const String localBackendIOS =
      'localhost:8080'; // Update with your Mac's IP if needed

  // Production backend address
  static const String productionBackend = 'tanafaso-3cituzoyra-ew.a.run.app';

  /// Get the base URL based on platform and environment
  static String getBaseUrl() {
    if (!useProdBackend) {
      if (Platform.isAndroid) {
        print('🔧 Using LOCAL backend: $localBackendAndroid');
        return localBackendAndroid;
      }
      if (Platform.isIOS) {
        // For iOS simulator, use localhost or your computer's local IP
        // If localhost doesn't work, replace with your Mac's IP address (e.g., '192.168.1.100:8080')
        print('🔧 Using LOCAL backend: $localBackendIOS');
        return localBackendIOS;
      }
    }

    // Production
    print('🌐 Using PRODUCTION backend: $productionBackend');
    return productionBackend;
  }

  /// Returns true if running in local development mode
  static bool get isLocal => !useProdBackend;

  /// Returns the protocol (http for local, https for production)
  static String get protocol => useProdBackend ? 'https' : 'http';
}
