class EnvConfig {
  // Production Base API URL
  static String baseUrl = 'https://api.mopy.co.in/api';

  // Local fallback (Android Emulator: 10.0.2.2:5000, Web/Desktop: localhost:5000)
  static String localBaseUrl = 'http://10.0.2.2:5000/api';

  // Connect timeout in seconds
  static const int connectTimeoutSeconds = 15;

  // Toggle offline/mock data fallback
  static bool enableOfflineFallback = true;
}
