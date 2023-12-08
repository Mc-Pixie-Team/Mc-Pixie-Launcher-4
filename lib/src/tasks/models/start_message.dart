import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';

class StartMessage {
  Api handler;
  UMF modpackData;
  String processId;

  Api get getHandler => handler;
  UMF get getModpackData => modpackData;
  String get getProcessId => processId;
  StartMessage({required this.handler, required this.modpackData, required this.processId});
}
