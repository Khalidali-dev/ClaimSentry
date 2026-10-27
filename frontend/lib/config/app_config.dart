import 'package:flutter/foundation.dart';

/// Configuration manager for ClaimSentry frontend environment settings.
/// Configured for unified Vercel serverless deployment (same-origin `/api`)
/// and local development.
class AppConfig {
  /// Default production serverless path on Vercel (same-origin /api)
  static const String defaultProductionBackendUrl = '/api';

  /// Default local development backend URL (port 7860)
  static const String defaultLocalBackendUrl = 'http://localhost:7860';

  /// Compile-time environment variable: pass `--dart-define=BACKEND_URL=https://...`
  static const String _envBackendUrl = String.fromEnvironment('BACKEND_URL');

  /// Runtime configurable override (allows dynamic toggles or testing overrides)
  static String? _customBackendUrl;

  /// Returns the active backend base URL.
  /// Priority:
  /// 1. Runtime override via [setBackendUrl]
  /// 2. Compile-time environment variable via `--dart-define=BACKEND_URL=...`
  /// 3. Default production serverless route `/api`
  static String get backendBaseUrl {
    if (_customBackendUrl != null && _customBackendUrl!.trim().isNotEmpty) {
      return _customBackendUrl!.trim();
    }
    if (_envBackendUrl.trim().isNotEmpty) {
      return _envBackendUrl.trim();
    }
    return defaultProductionBackendUrl;
  }

  /// Sets a custom backend base URL at runtime.
  static void setBackendUrl(String? url) {
    _customBackendUrl = url;
  }

  /// Full endpoint for the multi-agent appeal audit pipeline
  static String get runEndpoint => '$backendBaseUrl/run';

  /// Full endpoint for the health check endpoint
  static String get healthEndpoint => '$backendBaseUrl/health';

  /// Resolves an endpoint path (e.g., 'run', 'health', '/api/run') to a full, valid Uri.
  /// If running on Flutter Web with a relative path like '/api', resolves against [Uri.base.origin].
  /// If running in VM/tests, resolves against 'http://localhost:7860'.
  static Uri resolveUri(String path) {
    final base = backendBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // If base is a full absolute URL (e.g. http://localhost:7860 or https://...):
    if (base.startsWith('http://') || base.startsWith('https://')) {
      final cleanBase =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      return Uri.parse('$cleanBase$normalizedPath');
    }

    // Relative base (like '/api' or ''):
    final cleanBase = base.replaceAll(RegExp(r'^/|/$'), '');
    final cleanPath = path.replaceAll(RegExp(r'^/'), '');
    final relativeTarget =
        cleanBase.isEmpty ? cleanPath : '$cleanBase/$cleanPath';

    if (kIsWeb) {
      final origin = Uri.base.origin;
      return Uri.parse('$origin/$relativeTarget');
    }

    // In unit tests / VM fallback:
    return Uri.parse('http://localhost:7860/$relativeTarget');
  }

  /// Returns true if currently pointing to localhost or loopback address
  static bool get isLocal =>
      backendBaseUrl.contains('localhost') ||
      backendBaseUrl.contains('127.0.0.1');
}
