import 'package:mclauncher4/src/tasks/apis/api.dart';

class StartMessage {
  Api handler;
  Map modpackData;
  String processId;

  Api get getHandler => handler;
  Map get getModpackData => modpackData;
  String get getProcessId => processId;
  StartMessage(
      {required this.handler,
      required this.modpackData,
      required this.processId});
}