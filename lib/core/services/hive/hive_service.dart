abstract class HiveService {
  Future<void> put<T>(String boxName, dynamic key, T value);
  Future<T?> get<T>(String boxName, dynamic key);
  Future<void> delete<T>(String boxName, dynamic key);
  Future<void> clear<T>(String boxName);
  Future<List<T>> getAll<T>(String boxName);
  Future<void> putAll<T>(String boxName, Map<dynamic, T> entries);
  Future<bool> containsKey<T>(String boxName, dynamic key);
}
