import 'dart:isolate';

import 'package:mclauncher4/src/tasks/downloadState.dart';

class InstallerMessage { 
  MainState mainState;
  double progress;
  double mainprogress;
  var installState;
  SendPort? sendPort;

  MainState get getmainState => mainState;
  double get getprogress => progress;
  double get getmainprogress => mainprogress;
  get getinstallState => installState;
  SendPort? get getsendPort => sendPort;

  bool get isSendPort => sendPort == null ? false : true;

  InstallerMessage({
    required this.mainState,
    required this.installState,
    required this.progress,
    required this.mainprogress,
    this.sendPort,
  });
}

class IsolateBreaker {
  String? message;

  String get getmessage => message ?? "0";

  IsolateBreaker({this.message});
}
