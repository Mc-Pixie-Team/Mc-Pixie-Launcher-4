import 'dart:isolate';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';

class InstallerMessage {
  InstallState installState;
  String state;
  double progress;
  SendPort? sendPort;

  InstallState get getInstallerState => installState;
  String get getState => state;
  double get getprogress => progress;
  SendPort? get getsendPort => sendPort;

  bool get isSendPort => sendPort == null ? false : true;

  InstallerMessage({
    required this.state,
    required this.installState,
    required this.progress,
    this.sendPort,
  });
}

class IsolateBreaker {
  String? message;

  String get getmessage => message ?? "0";

  IsolateBreaker({this.message});
}
