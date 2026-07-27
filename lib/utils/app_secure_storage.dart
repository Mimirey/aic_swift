
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  static Future<String?> read({required String key}) => _storage.read(key: key);

  static Future<void> delete({required String key}) =>
      _storage.delete(key: key);

  static Future<void> deleteAll() => _storage.deleteAll();
}
