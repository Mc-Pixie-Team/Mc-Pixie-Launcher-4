import 'dart:async';
import 'dart:convert';

import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/murmur_hash.dart';

import 'package:http/http.dart' as http;

class CurseforgeFiles {
  Map<String, String> userHeader = {
    "Accept": "application/json",
    "content-type": "application/json",
    "x-api-key":
        "\$2a\$10\$zApu4/n/e1nylJMTZMv5deblPpAWUHXc226sEIP1vxCjlYQoQG3QW",
  };

  final baseUrl = "https://api.curseforge.com";

  Future<int> _getFingerprint(String filepath) async {
    var buffer = await murmur2.get_jar_contents(filepath);
    if (buffer.length < 1) throw "file buffer equals 0";
    int result = await murmur2.compute_hash(buffer);
    return result;
  }

  onError(e) {
    print("error");
    print(e);
  }

  Future<UMF> getFileData(String filepath) async {
    int fingerprint = await _getFingerprint(filepath);
    var body = jsonEncode({
      "fingerprints": [fingerprint]
    });
    var client = http.Client();
    var res = await (client
            .post(Uri.parse('$baseUrl/v1/fingerprints/'),
                headers: userHeader, body: body)
            .timeout(const Duration(seconds: 2)))
        .timeout(Duration(seconds: 1));

    if (res.statusCode != 200) throw "Nothing Found!";
    final file =
        jsonDecode(utf8.decode(res.bodyBytes))["data"]["exactMatches"] as List;

    if (file.isEmpty) throw "Nothing Found!";
    var res2 = await http
        .get(Uri.parse('$baseUrl/v1/mods/${file[0]["id"]}'),
            headers: userHeader)
        .timeout(const Duration(seconds: 2));

    final mod = jsonDecode(utf8.decode(res2.bodyBytes))["data"];
    mod["filepath"] = filepath;
    print(
        "filepath: $filepath, fingerprint:$fingerprint, name: ${mod["name"]}");
    return UMF(
      name: mod["name"],
      author: mod["authors"][0]["name"],
      icon: mod["logo"]["url"],
      downloads: mod["downloadCount"],
      type: ObjectType.mod,
      original: mod,
    );
  }
}
