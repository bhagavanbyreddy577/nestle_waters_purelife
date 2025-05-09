import 'dart:convert';
import 'package:nestle_waters_purelife/core/services/sharedPreferences/shared_pref_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefServiceImpl implements SharedPrefService {
  final SharedPreferences _prefs;

  SharedPrefServiceImpl(this._prefs);

  @override
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  @override
  Future<bool> saveObject<T>(
      String key,
      T object,
      Map<String, dynamic> Function(T) toJson,
      ) async {
    final jsonString = jsonEncode(toJson(object));
    return await _prefs.setString(key, jsonString);
  }

  @override
  Future<T?> getObject<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return fromJson(jsonMap);
    } catch (e) {
      // Safe loading: return null if JSON is corrupt
      return null;
    }
  }

  @override
  Future<bool> saveObjectList<T>(
      String key,
      List<T> objects,
      Map<String, dynamic> Function(T) toJson,
      ) async {
    final List<String> jsonStringList = objects.map((obj) {
      final jsonMap = toJson(obj);
      return jsonEncode(jsonMap);
    }).toList();

    return await _prefs.setStringList(key, jsonStringList);
  }

  @override
  Future<List<T>> getObjectList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    final List<String>? jsonStringList = _prefs.getStringList(key);
    if (jsonStringList == null) return [];

    final List<T> result = [];

    for (var jsonString in jsonStringList) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        result.add(fromJson(jsonMap));
      } catch (e) {
        // Skip corrupt item
        continue;
      }
    }

    return result;
  }
}

/// TODO: Example usages (Need to remove in production.
/*// Example usage to save an object
// Assuming UserModel has a toJson method or implemented freezed
await localStorage.saveObject<UserModel>(
'user_model',
user,
(u) => u.toJson(),
);

// Example usage to get an object
final user = await localStorage.getObject<UserModel>(
'user_model',
UserModel.fromJson,
);

// Example usage to save list of objects
await localStorage.saveObjectList<UserModel>(
'user_list',
users,
(u) => u.toJson(),
);

// Example usage to get list of objects
final users = await localStorage.getObjectList<UserModel>(
'user_list',
UserModel.fromJson,
);*/


