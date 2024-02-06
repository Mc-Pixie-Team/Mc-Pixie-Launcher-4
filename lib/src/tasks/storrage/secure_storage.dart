import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
 static FlutterSecureStorage storage = new FlutterSecureStorage();

 static Future<bool> isKeyRegistered(String key) async => await storage.containsKey(key: key);

 static writeSecureData(String key, String value) async {
  await storage.delete(key: key);
    await storage.write(key: key, value: value);
  }

 static readSecureData(String key) async {
    String? value = await storage.read(key: key);
    if (value == null) {
      throw Exception("no value found for key: " + key);
    }
    return value;
  }

 static deleteSecureData(String key) async {
    await storage.delete(key: key);
  }
}
