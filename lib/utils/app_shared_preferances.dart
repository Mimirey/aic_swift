
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferances {
  static final _prefs = SharedPreferences.getInstance();

  static Future<String> read(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key) ?? "";
  }

  static Future<List<String>> readList(String key) async {
    final prefs = await _prefs;
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> write(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  static Future<void> writeList(String key, List<String> value) async {
    final prefs = await _prefs;
    await prefs.setStringList(key, value);
  }

  static Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
