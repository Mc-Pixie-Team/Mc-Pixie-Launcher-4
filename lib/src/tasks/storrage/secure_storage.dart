import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> isKeyRegistered(String key) async => await storage.containsKey(key: key);

  writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  readSecureData(String key) async {
    String? value = await storage.read(key: key);
    if (value == null) {
      throw Exception("no value found for key: " + key);
    }
    return value;
  }

  deleteSecureData(String key) async {
    await storage.delete(key: key);
  }
}
