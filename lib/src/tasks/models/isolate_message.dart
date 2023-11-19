import 'dart:isolate';

import 'package:mclauncher4/src/tasks/models/download_states.dart';



class InstallerMessage { 
  MainState mainState;
  double progress;
  SendPort? sendPort;

  MainState get getmainState => mainState;
  double get getprogress => progress;
  SendPort? get getsendPort => sendPort;

  bool get isSendPort => sendPort == null ? false : true;

  InstallerMessage({
    required this.mainState,
    required this.progress,
    this.sendPort,
  });
}

class IsolateBreaker {
  String? message;

  String get getmessage => message ?? "0";

  IsolateBreaker({this.message});
}
