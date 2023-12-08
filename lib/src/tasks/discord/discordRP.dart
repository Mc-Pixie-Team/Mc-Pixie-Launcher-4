// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';

class DiscordRP {
  DiscordRP._internal();

  static final DiscordRP _instance = DiscordRP._internal();

  factory DiscordRP() {
    return _instance;
  }

  Process? csharpProcess;

  Future<void> initCS(String appID) async {
    if (csharpProcess != null) {
      throw DiscordRPException("The process is already initialized!", 403);
    }
    var serviceExecutable = 'C:/Program Files/dotnet/dotnet.exe'; // literally the .NET CLI
    var serviceArgs = ['run', appID]; // or .EXE if on Windows...
    // csharpProcess = await Process.start(serviceExecutable, serviceArgs, workingDirectory: "C:\\Users\\ancie\\Mc-Pixie-Launcher-4\\discordCSApp");
    // print(csharpProcess);
// Parse messages incoming from C# -> Dart
    dynamic onDataReceived(event) {
      try {
        var strMessage = utf8.decode(event);
        var strJson = strMessage
            .split('\r\n')
            .where((element) => !element.contains('Content-Length'))
            .where((element) => element.trim().length > 0)
            .first;

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
      try {
        var strMessage = utf8.decode(event);
        var strJson = strMessage
            .split('\r\n')
            .where((element) => !element.contains('Content-Length'))
            .where((element) => element.trim().length > 0)
            .first;

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

    // csharpProcess!.stdout.forEach(onDataReceived);
    // csharpProcess!.stderr.forEach(onErrorReceived);
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
    //  (csharpProcess!).stdin.write(messagePayload);
// TODO: track the message ID if replies are important
  }

  bool update(RitchPresence data) {
    if (csharpProcess == null) {
      throw DiscordRPException("The csharpProcess is null! (not initialized)", 10);
    }

    print(data.toMap());

    Map message = {
      "jsonrpc": "2.0",
      "method": "SetRP",
      "params": [jsonEncode(data.toMap())],
      "id": 2
    };
    var jsonEncodedBody = jsonEncode(message);
    var contentLengthHeader = 'Content-Length: ${jsonEncodedBody.length}';
    var messagePayload = contentLengthHeader + '\r\n\r\n${jsonEncodedBody}';
    // (csharpProcess!).stdin.write(messagePayload);
    return true;
  }

  bool clear() {
    if (csharpProcess == null) {
      throw DiscordRPException("The csharpProcess is null! (not initialized)", 10);
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
    if (csharpProcess == null) {
      throw DiscordRPException("The csharpProcess is null! (not initialized)", 10);
    }
    csharpProcess!.kill();
    csharpProcess = null;
    return true;
  }
}

class DiscordRPException implements Exception {
  String cause;
  int id;
  DiscordRPException(this.cause, this.id);
}

/* {
                        'Details': 'Hello from C#',
                        'State': 'Playing with Your mom',
                        'Timestamps': {'Start': 1672549067},
                        'Assets': {'LargeImage': 'test', 'LargeText': 'ancientxfire', 'SmallImage': 'test', 'SmallText': 'smol'},
                        'Secrets': {'Match': 'ae488379-351d-4a4f-ad32-2b9b01c91657-2', 'Join': 'MTI4NzM0OjFpMmhuZToxMjMxMjM='},
                        'Party': {
                          'Id': 'ae488379-351d-4a4f-ad32-2b9b01c91657',
                          'Size': {'CurrentSize': Random().nextInt(100), 'MaxSize': 100},
                          
                        }
                      } */
class RitchPresence {
  String details;
  String state;
  RitchPresenceTimestamp? timestamps;
  RitchPresenceAssets? assets;
  RitchPresenceParty? party;
  RitchPresenceSecrets? secrets;
  RitchPresenceType type;

  RitchPresence({
    required this.details,
    required this.state,
    this.timestamps,
    this.assets,
    this.party,
    this.secrets,
    required this.type,
  });

  Map toMap() {
    Map returnValue = {'Details': details, 'State': state, 'Type': type.toInt()};
    if (timestamps != null) {
      returnValue.addAll({"Timestamps": timestamps!.toMap()});
    }
    if (assets != null) {
      returnValue.addAll({"Assets": assets!.toMap()});
    }
    if (party != null) {
      returnValue.addAll({"Party": party!.toMap()});
    }
    if (secrets != null) {
      returnValue.addAll({"Secrets": secrets!.toMap()});
    }
    return returnValue;
  }
}

class RitchPresenceTimestamp {
  int Start;
  int? Stop;
  RitchPresenceTimestamp({required this.Start, this.Stop});
  Map toMap() {
    Map returnValue = {
      'Start': Start,
    };
    if (Stop != null) {
      returnValue.addAll({"Stop": Stop});
    }
    return returnValue;
  }
}

class RitchPresenceAssets {
  String LargeImage;
  String LargeText;
  String? SmallImage;
  String? SmallText;

  RitchPresenceAssets({required this.LargeImage, required this.LargeText, this.SmallImage, this.SmallText});
  Map toMap() {
    Map returnValue = {'LargeImage': LargeImage, 'LargeText': LargeText};
    if (SmallImage != null) {
      returnValue.addAll({"SmallImage": SmallImage});
    }
    if (SmallText != null) {
      returnValue.addAll({"SmallText": SmallText});
    }

    return returnValue;
  }
}

class RitchPresenceParty {
  String Id;
  RitchPresencePartySize Size;

  RitchPresenceParty({required this.Id, required this.Size});
  Map toMap() {
    Map returnValue = {'Id': Id, 'Size': Size.toMap()};
    return returnValue;
  }
}

class RitchPresencePartySize {
  int CurrentSize;
  int MaxSize;

  RitchPresencePartySize({required this.CurrentSize, required this.MaxSize});
  Map toMap() {
    Map returnValue = {'CurrentSize': CurrentSize, 'MaxSize': MaxSize};
    return returnValue;
  }
}

class RitchPresenceSecrets {
  String Match;
  String Join;
  String? Spectate;
  RitchPresenceSecrets({required this.Match, required this.Join, this.Spectate});
  Map toMap() {
    Map returnValue = {'Match': Match, 'Join': Join};
    if (Spectate != null) {
      returnValue.addAll({'Spectate': Spectate});
    }
    return returnValue;
  }
}

class RitchPresenceType {
  static int get playing => 0;
  static int get streaming => 1;
  static int get listening => 2;
  static int get watching => 3;
  //static int get custom => 4;
  static int get competing => 5;
  late int _returnValue;

  RitchPresenceType(int index) {
    this._returnValue = index;
  }
  int toInt() {
    return _returnValue;
  }
}
