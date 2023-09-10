import 'dart:async';
import 'dart:io';
import 'dart:convert';

class DiscordRP {
  DiscordRP._internal();

  static final DiscordRP _instance = DiscordRP._internal();

  factory DiscordRP() {
    return _instance;
  }

  Process? csharpProcess;

  Future<void> initCS() async {
    var serviceExecutable = 'C:\\Program Files\\dotnet\\dotnet.exe'; // literally the .NET CLI
    var serviceArgs = ['run']; // or .EXE if on Windows...
    csharpProcess =
        await Process.start(serviceExecutable, serviceArgs, workingDirectory: "C:\\Users\\zepat\\Mc-Pixie-Launcher-4\\discordCSApp");
    print(csharpProcess);
// Parse messages incoming from C# -> Dart
    dynamic onDataReceived(event) {
      try {
        var strMessage = utf8.decode(event);
        var strJson =
            strMessage.split('\r\n').where((element) => !element.contains('Content-Length')).where((element) => element.trim().length > 0).first;

        dynamic result = jsonDecode(strJson);
        print(result);
      } catch (e) {
        print("\x1B[31m=== Error!!! Message does not conform to JSON RPC standarts!! ===\x1B[0m");
        var strMessage = utf8.decode(event);
        print('\x1B[31m$strMessage\x1B[0m');
        print("\x1B[31m=================================================================\x1B[0m");
      }
      //TODO: to implement message replies, sync up the message ID here
      //TODO: handle the payload of the JSON RPC message "result"
    }

    dynamic onErrorReceived(event) {
      var strMessage = utf8.decode(event);
      var strJson =
          strMessage.split('\r\n').where((element) => !element.contains('Content-Length')).where((element) => element.trim().length > 0).first;

      dynamic result = jsonDecode(strJson);
      print(result);
      //TODO: to implement message replies, sync up the message ID here
      //TODO: handle the payload of the JSON RPC message "result"
    }

    csharpProcess!.stdout.forEach(onDataReceived);
    csharpProcess!.stderr.forEach(onErrorReceived);
// Format outgoing messages
    Map message = {
      "jsonrpc": "2.0",
      "method": "Ping",
      "params": ["Hello worker"],
      "id": 1
    };
    var jsonEncodedBody = jsonEncode(message);
    var contentLengthHeader = 'Content-Length: ${jsonEncodedBody.length}';
    var messagePayload = contentLengthHeader + '\r\n\r\n${jsonEncodedBody}';
    (csharpProcess!).stdin.write(messagePayload);
// TODO: track the message ID if replies are important
  }

  bool update() {
    if (csharpProcess == null) {
      throw "The csharpProcess is null! (not initialized)";
    }

    print(csharpProcess);
    Map data = {
      'Details': 'Hello from C#',
      'State': 'Playing with Megulicious',
      'Timestamps': {'Start': 1672539067},
      'Assets': {'LargeImage': 'test', 'LargeText': 'ancientxfire', 'SmallImage': 'test', 'SmallText': 'smol'},
      'Secrets': {'Match': 'ae488379-351d-4a4f-ad32-2b9b01c91657-2', 'Join': 'MTI4NzM0OjFpMmhuZToxMjMxMjM='},
      'Party': {
        'Id': 'ae488379-351d-4a4f-ad32-2b9b01c91657',
        'Size': {'CurrentSize': 10, 'MaxSize': 100},
        'Privacy': 2
      }
    };
    Map message = {
      "jsonrpc": "2.0",
      "method": "SetRP",
      "params": [jsonEncode(data)],
      "id": 2
    };
    var jsonEncodedBody = jsonEncode(message);
    var contentLengthHeader = 'Content-Length: ${jsonEncodedBody.length}';
    var messagePayload = contentLengthHeader + '\r\n\r\n${jsonEncodedBody}';
    (csharpProcess!).stdin.write(messagePayload);
    return true;
  }

  bool clear() {
    if (csharpProcess == null) {
      throw "The csharpProcess is null! (not initialized)";
    }
    Map message = {
      "jsonrpc": "2.0",
      "method": "RemoveRP",
      "params": ["clear"],
      "id": 2
    };
    var jsonEncodedBody = jsonEncode(message);
    var contentLengthHeader = 'Content-Length: ${jsonEncodedBody.length}';
    var messagePayload = contentLengthHeader + '\r\n\r\n${jsonEncodedBody}';
    (csharpProcess!).stdin.write(messagePayload);
    return true;
  }

  bool terminate() {
    return true;
  }
}
