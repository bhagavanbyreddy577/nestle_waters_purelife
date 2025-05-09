abstract class SharedPrefService {

  Future<bool> saveString(String key, String value);
  Future<String?> getString(String key);

  Future<bool> saveInt(String key, int value);
  Future<int?> getInt(String key);

  Future<bool> saveBool(String key, bool value);
  Future<bool?> getBool(String key);

  Future<bool> remove(String key);
  Future<bool> clear();

  // Save single object
  Future<bool> saveObject<T>(String key, T object, Map<String, dynamic> Function(T) toJson);

  // Get single object
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic>) fromJson);

  // Save list of objects
  Future<bool> saveObjectList<T>(String key, List<T> objects, Map<String, dynamic> Function(T) toJson);

  // Get list of objects
  Future<List<T>> getObjectList<T>(String key, T Function(Map<String, dynamic>) fromJson);
}
