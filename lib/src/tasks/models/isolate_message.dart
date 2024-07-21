import 'dart:isolate';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';

class InstallerMessage {
  InstallState installState;
  String state;
  double progress;
  SendPort? sendPort;
  UMF? umfData;

  InstallState get getInstallerState => installState;
  String get getState => state;
  double get getprogress => progress;
  UMF? get getUMFData => umfData;
  SendPort? get getsendPort => sendPort;

  bool get isSendPort => sendPort == null ? false : true;
  bool get isUMF => umfData == null ? false : true;

  InstallerMessage({
    required this.state,
    required this.installState,
    required this.progress,
    this.umfData,
    this.sendPort,
  });
}

class IsolateBreaker {
  String? message;

  String get getmessage => message ?? "0";

  IsolateBreaker({this.message});
}
