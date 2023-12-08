import 'dart:io';

class Furry {
  Future<void> e621(bool save) async {
    var result = await Process.run(
        "rundll32", ['url.dll,FileProtocolHandler', save ? "https://e926.net/posts" : "https://e621.net/posts"]);
  }
}
