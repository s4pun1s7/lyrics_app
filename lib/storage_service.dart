import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<void> init() async {
    // For mobile/desktop, use path_provider for Hive location
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
  }

  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  static Future<void> save(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  static Future<dynamic> get(String boxName, String key) async {
    final box = await openBox(boxName);
    return box.get(key);
  }

  static Future<void> delete(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  static Future<void> clear(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }
}
