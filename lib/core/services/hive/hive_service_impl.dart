import 'package:hive_flutter/hive_flutter.dart';
import 'package:nestle_waters_purelife/core/services/hive/hive_service.dart';

class HiveServiceImpl implements HiveService {
  final Box hiveBox;

  HiveServiceImpl(this.hiveBox);

  @override
  Future<void> put<T>(String boxName, dynamic key, T value) async {
    //final box = await Hive.openBox<T>(boxName);
    await hiveBox.put(key, value);
  }

  @override
  Future<T?> get<T>(String boxName, dynamic key) async {
    //final box = await Hive.openBox<T>(boxName);
    return hiveBox.get(key);
  }

  @override
  Future<void> delete<T>(String boxName, dynamic key) async {
    //final box = await Hive.openBox<T>(boxName);
    await hiveBox.delete(key);
  }

  @override
  Future<void> clear<T>(String boxName) async {
    //final box = await Hive.openBox<T>(boxName);
    await hiveBox.clear();
  }

  @override
  Future<List<T>> getAll<T>(String boxName) async {
    //final box = await Hive.openBox<T>(boxName);
    return hiveBox.values.toList().cast<T>();
  }

  @override
  Future<void> putAll<T>(String boxName, Map<dynamic, T> entries) async {
    //final box = await Hive.openBox<T>(boxName);
    await hiveBox.putAll(entries);
  }

  @override
  Future<bool> containsKey<T>(String boxName, dynamic key) async {
    //final box = await Hive.openBox<T>(boxName);
    return hiveBox.containsKey(key);
  }
}
