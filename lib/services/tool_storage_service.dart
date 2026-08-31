class ToolStorageService {
  static final Map<String, String> _memoryStorage = {};

  static Future<void> setString(String key, String value) async {
    _memoryStorage[key] = value;
  }

  static Future<String?> getString(String key) async {
    return _memoryStorage[key];
  }
}
