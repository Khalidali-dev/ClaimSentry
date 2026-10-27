/// Configuration manager for ClaimSentry frontend environment settings.
/// Configured for Hugging Face Spaces backend and Vercel frontend deployments.
class AppConfig {
  /// Default production Hugging Face Spaces backend URL
  static const String defaultProductionBackendUrl =
      'https://khalidali-dev-claimsentry-backend.hf.space';

  /// Default local development backend URL (Hugging Face Spaces local port 7860)
  static const String defaultLocalBackendUrl = 'http://localhost:7860';

  /// Compile-time environment variable: pass `--dart-define=BACKEND_URL=https://...`
  static const String _envBackendUrl = String.fromEnvironment('BACKEND_URL');

  /// Runtime configurable override (allows dynamic toggles or testing overrides)
  static String? _customBackendUrl;

  /// Returns the active backend base URL.
  /// Priority:
  /// 1. Runtime override via [setBackendUrl]
  /// 2. Compile-time environment variable via `--dart-define=BACKEND_URL=...`
  /// 3. Default production Hugging Face Space URL for live deployments
  static String get backendBaseUrl {
    if (_customBackendUrl != null && _customBackendUrl!.trim().isNotEmpty) {
      return _customBackendUrl!.trim();
    }
    if (_envBackendUrl.trim().isNotEmpty) {
      return _envBackendUrl.trim();
    }
    // Point directly to live Hugging Face Space backend URL
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

  /// Returns true if currently pointing to localhost or loopback address
  static bool get isLocal =>
      backendBaseUrl.contains('localhost') ||
      backendBaseUrl.contains('127.0.0.1');
}
