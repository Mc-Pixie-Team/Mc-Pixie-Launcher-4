import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';

class StartMessage {
  Api handler;
  UMF modpackData;
  String processId;
  Version? version;

  Api get getHandler => handler;
  UMF get getModpackData => modpackData;
  String get getProcessId => processId;
  Version? get getversion => version;
  StartMessage({required this.handler, required this.modpackData, required this.processId, this.version});
}
